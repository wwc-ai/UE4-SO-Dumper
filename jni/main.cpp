/**
 * UE4 SO Dumper
 * Author: wwc-ai
 * Version: 1.1.0
 * Description: 用于从Android进程内存中Dump UE4 SO文件的工具
 * License: MIT
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <errno.h>
#include <time.h>
#include <dirent.h>
#include <elf.h>

#define VERSION "1.1.0"
#define AUTHOR "wwc-ai"
#define BANNER \
    "╔══════════════════════════════════════════════════════════╗\n" \
    "║              UE4 SO Dumper v" VERSION "                      ║\n" \
    "║              Author: " AUTHOR "                             ║\n" \
    "║       https://github.com/wwc-ai/UE4-SO-Dumper      ║\n" \
    "╚══════════════════════════════════════════════════════════╝\n"

#define COLOR_RESET   "\033[0m"
#define COLOR_RED     "\033[31m"
#define COLOR_GREEN   "\033[32m"
#define COLOR_YELLOW  "\033[33m"
#define COLOR_BLUE    "\033[34m"
#define COLOR_MAGENTA "\033[35m"
#define COLOR_CYAN    "\033[36m"

// 内存区域信息结构
typedef struct {
    unsigned long start;
    unsigned long end;
    unsigned long offset;
    char perms[5];
    char path[256];
} MemoryRegion;

/**
 * 打印带颜色的日志
 */
void print_log(const char* color, const char* tag, const char* format, ...) {
    printf("%s[%s]%s ", color, tag, COLOR_RESET);
    
    va_list args;
    va_start(args, format);
    vprintf(format, args);
    va_end(args);
    
    printf("\n");
    fflush(stdout);
}

/**
 * 打印进度条
 */
void print_progress(unsigned long current, unsigned long total) {
    int bar_width = 50;
    float progress = (float)current / total;
    int pos = bar_width * progress;
    
    printf("\r%s[进度]%s [", COLOR_CYAN, COLOR_RESET);
    for (int i = 0; i < bar_width; ++i) {
        if (i < pos) printf("█");
        else if (i == pos) printf(">");
        else printf(" ");
    }
    printf("] %3d%% (%lu/%lu bytes)", (int)(progress * 100.0), current, total);
    fflush(stdout);
}

/**
 * 读取进程的内存映射信息
 */
int read_maps(int pid, const char* so_name, MemoryRegion** regions, int* count) {
    char maps_path[256];
    snprintf(maps_path, sizeof(maps_path), "/proc/%d/maps", pid);
    
    FILE* fp = fopen(maps_path, "r");
    if (!fp) {
        print_log(COLOR_RED, "错误", "无法打开 %s: %s", maps_path, strerror(errno));
        return -1;
    }
    
    print_log(COLOR_BLUE, "信息", "正在读取进程 %d 的内存映射...", pid);
    
    MemoryRegion* temp_regions = (MemoryRegion*)malloc(sizeof(MemoryRegion) * 1024);
    int region_count = 0;
    
    char line[1024];
    while (fgets(line, sizeof(line), fp)) {
        MemoryRegion region;
        unsigned long dev_major, dev_minor, inode;
        
        int ret = sscanf(line, "%lx-%lx %4s %lx %lx:%lx %lu %255s",
                        &region.start, &region.end, region.perms, &region.offset,
                        &dev_major, &dev_minor, &inode, region.path);
        
        if (ret >= 7) {
            // 查找包含指定SO名称的内存区域
            if (ret == 8 && strstr(region.path, so_name)) {
                memcpy(&temp_regions[region_count], &region, sizeof(MemoryRegion));
                region_count++;
                
                print_log(COLOR_GREEN, "发现", "0x%lx-0x%lx %s offset:0x%lx %s",
                         region.start, region.end, region.perms, region.offset, region.path);
            }
        }
    }
    
    fclose(fp);
    
    if (region_count == 0) {
        print_log(COLOR_RED, "错误", "未找到包含 '%s' 的内存映射", so_name);
        free(temp_regions);
        return -1;
    }
    
    *regions = temp_regions;
    *count = region_count;
    
    print_log(COLOR_GREEN, "成功", "共找到 %d 个内存区域", region_count);
    return 0;
}

/**
 * 计算总的内存大小
 */
unsigned long calculate_total_size(MemoryRegion* regions, int count) {
    unsigned long total = 0;
    for (int i = 0; i < count; i++) {
        total += (regions[i].end - regions[i].start);
    }
    return total;
}

/**
 * 修复ELF文件头 - 清除无效的Section Header Table信息
 */
int fix_elf_header(const char* filepath) {
    print_log(COLOR_BLUE, "修复", "正在修复ELF文件头...");
    
    int fd = open(filepath, O_RDWR);
    if (fd < 0) {
        print_log(COLOR_RED, "错误", "无法打开文件用于修复: %s", strerror(errno));
        return -1;
    }
    
    // 读取ELF魔数和类别
    unsigned char e_ident[16];
    if (read(fd, e_ident, 16) != 16) {
        print_log(COLOR_RED, "错误", "无法读取ELF头");
        close(fd);
        return -1;
    }
    
    // 检查ELF魔数
    if (e_ident[0] != 0x7f || e_ident[1] != 'E' || 
        e_ident[2] != 'L' || e_ident[3] != 'F') {
        print_log(COLOR_RED, "错误", "不是有效的ELF文件");
        close(fd);
        return -1;
    }
    
    int is_64bit = (e_ident[4] == 2);  // ELFCLASS64 = 2
    
    if (is_64bit) {
        // 64位ELF
        Elf64_Ehdr ehdr;
        lseek(fd, 0, SEEK_SET);
        if (read(fd, &ehdr, sizeof(ehdr)) != sizeof(ehdr)) {
            print_log(COLOR_RED, "错误", "无法读取64位ELF头");
            close(fd);
            return -1;
        }
        
        print_log(COLOR_YELLOW, "信息", "检测到64位ELF文件");
        print_log(COLOR_YELLOW, "信息", "原始 e_shoff: 0x%lx, e_shnum: %d, e_shstrndx: %d",
                 (unsigned long)ehdr.e_shoff, ehdr.e_shnum, ehdr.e_shstrndx);
        
        // 清除Section Header Table相关信息
        ehdr.e_shoff = 0;
        ehdr.e_shnum = 0;
        ehdr.e_shstrndx = 0;
        
        // 写回修复的头
        lseek(fd, 0, SEEK_SET);
        if (write(fd, &ehdr, sizeof(ehdr)) != sizeof(ehdr)) {
            print_log(COLOR_RED, "错误", "无法写入修复的ELF头");
            close(fd);
            return -1;
        }
    } else {
        // 32位ELF
        Elf32_Ehdr ehdr;
        lseek(fd, 0, SEEK_SET);
        if (read(fd, &ehdr, sizeof(ehdr)) != sizeof(ehdr)) {
            print_log(COLOR_RED, "错误", "无法读取32位ELF头");
            close(fd);
            return -1;
        }
        
        print_log(COLOR_YELLOW, "信息", "检测到32位ELF文件");
        print_log(COLOR_YELLOW, "信息", "原始 e_shoff: 0x%x, e_shnum: %d, e_shstrndx: %d",
                 (unsigned int)ehdr.e_shoff, ehdr.e_shnum, ehdr.e_shstrndx);
        
        // 清除Section Header Table相关信息
        ehdr.e_shoff = 0;
        ehdr.e_shnum = 0;
        ehdr.e_shstrndx = 0;
        
        // 写回修复的头
        lseek(fd, 0, SEEK_SET);
        if (write(fd, &ehdr, sizeof(ehdr)) != sizeof(ehdr)) {
            print_log(COLOR_RED, "错误", "无法写入修复的ELF头");
            close(fd);
            return -1;
        }
    }
    
    close(fd);
    print_log(COLOR_GREEN, "成功", "ELF文件头修复完成 (已清除Section Header信息)");
    return 0;
}

/**
 * Dump指定进程的SO文件
 */
int dump_so(int pid, const char* so_name) {
    MemoryRegion* regions = NULL;
    int region_count = 0;
    
    // 读取内存映射
    if (read_maps(pid, so_name, &regions, &region_count) != 0) {
        return -1;
    }
    
    // 查找基址（第一个可执行区域）
    unsigned long base_addr = 0;
    for (int i = 0; i < region_count; i++) {
        if (strchr(regions[i].perms, 'x')) {  // 可执行区域
            base_addr = regions[i].start;
            break;
        }
    }
    
    if (base_addr == 0) {
        print_log(COLOR_RED, "错误", "未找到可执行内存区域");
        free(regions);
        return -1;
    }
    
    print_log(COLOR_MAGENTA, "基址", "0x%lx", base_addr);
    
    // 创建输出目录
    char output_dir[256] = "./dump_output";
    mkdir(output_dir, 0755);
    
    // 生成输出文件名
    char output_file[512];
    time_t now = time(NULL);
    struct tm* t = localtime(&now);
    snprintf(output_file, sizeof(output_file), 
             "%s/libUE4_dump_0x%lx_%04d%02d%02d_%02d%02d%02d.so",
             output_dir, base_addr,
             t->tm_year + 1900, t->tm_mon + 1, t->tm_mday,
             t->tm_hour, t->tm_min, t->tm_sec);
    
    print_log(COLOR_CYAN, "输出", "文件路径: %s", output_file);
    
    // 打开内存文件
    char mem_path[256];
    snprintf(mem_path, sizeof(mem_path), "/proc/%d/mem", pid);
    
    int mem_fd = open(mem_path, O_RDONLY);
    if (mem_fd < 0) {
        print_log(COLOR_RED, "错误", "无法打开 %s: %s", mem_path, strerror(errno));
        print_log(COLOR_YELLOW, "提示", "请确保以root权限运行");
        free(regions);
        return -1;
    }
    
    // 创建输出文件
    int out_fd = open(output_file, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (out_fd < 0) {
        print_log(COLOR_RED, "错误", "无法创建输出文件: %s", strerror(errno));
        close(mem_fd);
        free(regions);
        return -1;
    }
    
    print_log(COLOR_BLUE, "开始", "正在Dump内存数据...");
    
    unsigned long total_size = calculate_total_size(regions, region_count);
    unsigned long dumped_size = 0;
    unsigned char* buffer = (unsigned char*)malloc(4096);
    
    // 遍历所有内存区域
    for (int i = 0; i < region_count; i++) {
        MemoryRegion* region = &regions[i];
        unsigned long region_size = region->end - region->start;
        
        print_log(COLOR_BLUE, "Dump", "区域 %d/%d: 0x%lx-0x%lx (%lu bytes) offset:0x%lx",
                 i + 1, region_count, region->start, region->end, region_size, region->offset);
        
        // 定位到内存位置
        if (lseek64(mem_fd, region->start, SEEK_SET) == -1) {
            print_log(COLOR_YELLOW, "警告", "无法定位到地址 0x%lx: %s", 
                     region->start, strerror(errno));
            // 填充零
            unsigned char zero_buffer[4096] = {0};
            for (unsigned long j = 0; j < region_size; j += 4096) {
                size_t write_size = (region_size - j > 4096) ? 4096 : (region_size - j);
                write(out_fd, zero_buffer, write_size);
            }
            dumped_size += region_size;
            continue;
        }
        
        // 定位输出文件到对应offset
        if (lseek64(out_fd, region->offset, SEEK_SET) == -1) {
            print_log(COLOR_RED, "错误", "无法定位输出文件到offset 0x%lx", region->offset);
            continue;
        }
        
        // 读取并写入数据
        unsigned long read_size = 0;
        while (read_size < region_size) {
            size_t to_read = (region_size - read_size > 4096) ? 4096 : (region_size - read_size);
            ssize_t n = read(mem_fd, buffer, to_read);
            
            if (n <= 0) {
                print_log(COLOR_YELLOW, "警告", "读取失败，填充零");
                memset(buffer, 0, to_read);
                n = to_read;
            }
            
            write(out_fd, buffer, n);
            read_size += n;
            dumped_size += n;
            
            // 更新进度条
            print_progress(dumped_size, total_size);
        }
    }
    
    printf("\n");
    
    free(buffer);
    close(mem_fd);
    close(out_fd);
    free(regions);
    
    // 修复ELF文件头
    if (fix_elf_header(output_file) != 0) {
        print_log(COLOR_YELLOW, "警告", "ELF文件头修复失败，但dump已完成");
    }
    
    // 获取文件大小
    struct stat st;
    stat(output_file, &st);
    
    print_log(COLOR_GREEN, "完成", "Dump成功！");
    print_log(COLOR_GREEN, "文件", "%s", output_file);
    print_log(COLOR_GREEN, "大小", "%ld bytes (%.2f MB)", st.st_size, st.st_size / 1024.0 / 1024.0);
    
    return 0;
}

/**
 * 显示帮助信息
 */
void show_help(const char* prog_name) {
    printf(BANNER);
    printf("\n使用方法:\n");
    printf("  %s <PID> [SO名称]\n\n", prog_name);
    printf("参数说明:\n");
    printf("  PID      - 目标进程ID\n");
    printf("  SO名称   - 要Dump的SO文件名（可选，默认为libUE4.so）\n\n");
    printf("示例:\n");
    printf("  %s 12345                # Dump进程12345的libUE4.so\n", prog_name);
    printf("  %s 12345 libUE4.so      # 同上\n", prog_name);
    printf("  %s 12345 libil2cpp.so   # Dump进程12345的libil2cpp.so\n\n", prog_name);
    printf("注意事项:\n");
    printf("  1. 需要root权限运行\n");
    printf("  2. Dump的文件将保存在 ./dump_output 目录\n");
    printf("  3. 文件名格式: libUE4_dump_0x<基址>_<时间戳>.so\n\n");
}

/**
 * 主函数
 */
int main(int argc, char* argv[]) {
    // 显示Banner
    printf(BANNER);
    printf("\n");
    
    // 检查参数
    if (argc < 2) {
        print_log(COLOR_RED, "错误", "参数不足");
        show_help(argv[0]);
        return 1;
    }
    
    // 解析PID
    int pid = atoi(argv[1]);
    if (pid <= 0) {
        print_log(COLOR_RED, "错误", "无效的PID: %s", argv[1]);
        return 1;
    }
    
    // 获取SO名称
    const char* so_name = (argc >= 3) ? argv[2] : "libUE4.so";
    
    print_log(COLOR_CYAN, "目标", "PID: %d, SO: %s", pid, so_name);
    
    // 检查进程是否存在
    char proc_path[256];
    snprintf(proc_path, sizeof(proc_path), "/proc/%d", pid);
    if (access(proc_path, F_OK) != 0) {
        print_log(COLOR_RED, "错误", "进程 %d 不存在", pid);
        return 1;
    }
    
    // 检查权限
    if (geteuid() != 0) {
        print_log(COLOR_YELLOW, "警告", "建议使用root权限运行以避免权限问题");
    }
    
    printf("\n");
    
    // 执行Dump
    time_t start_time = time(NULL);
    int ret = dump_so(pid, so_name);
    time_t end_time = time(NULL);
    
    printf("\n");
    
    if (ret == 0) {
        print_log(COLOR_GREEN, "总结", "Dump完成，耗时: %ld 秒", end_time - start_time);
        printf("\n");
        printf("%s═══════════════════════════════════════════════════════════%s\n", 
               COLOR_GREEN, COLOR_RESET);
        printf("%s  Dump完成！现在可以使用IDA Pro分析SO文件了！  %s\n", 
               COLOR_GREEN, COLOR_RESET);
        printf("%s═══════════════════════════════════════════════════════════%s\n", 
               COLOR_GREEN, COLOR_RESET);
        printf("\n");
        return 0;
    } else {
        print_log(COLOR_RED, "失败", "Dump失败");
        return 1;
    }
}
