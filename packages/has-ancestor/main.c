// has-ancestor: Exits 0 if any ancestor process matches the given name, 1 otherwise.
// Used as a guard: `has-ancestor fish || exec fish -l`
//
// Linux: reads /proc/<pid>/comm and /proc/<pid>/stat
// macOS: uses sysctl KERN_PROC

#include <stdio.h>
#include <string.h>
#include <unistd.h>

#ifdef __APPLE__
#include <sys/sysctl.h>
#endif

// Check if `pid` matches `name` and get its parent in a single lookup.
// Returns the parent PID, 0 if pid matches name, or -1 on error.
static pid_t check_and_get_ppid(pid_t pid, const char *name) {
#ifdef __linux__
    // Read comm to check the process name.
    char path[64];
    snprintf(path, sizeof(path), "/proc/%d/comm", (int)pid);
    FILE *f = fopen(path, "r");
    if (!f) {
        return -1;
    }

    char comm[256];
    if (!fgets(comm, sizeof(comm), f)) {
        fclose(f);
        return -1;
    }
    fclose(f);

    comm[strcspn(comm, "\n")] = '\0';
    if (strcmp(comm, name) == 0) {
        return 0;
    }

    // Not a match, read stat for the parent PID.
    // Format: pid (comm) state ppid ...
    snprintf(path, sizeof(path), "/proc/%d/stat", (int)pid);
    f = fopen(path, "r");
    if (!f) {
        return -1;
    }

    char buf[512];
    if (!fgets(buf, sizeof(buf), f)) {
        fclose(f);
        return -1;
    }

    fclose(f);

    // comm can contain parens, so find the last ')' to skip past it.
    char *close_paren = strrchr(buf, ')');
    if (!close_paren) {
        return -1;
    }

    char state;
    pid_t ppid;
    if (sscanf(close_paren + 1, " %c %d", &state, &ppid) != 2) {
        return -1;
    }

    return ppid;

#elif defined(__APPLE__)
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, (int)pid};
    struct kinfo_proc info;
    size_t size = sizeof(info);

    if (sysctl(mib, 4, &info, &size, NULL, 0) != 0) {
        return -1;
    }

    // Note: p_comm is truncated to MAXCOMLEN (16) characters on macOS.
    if (strcmp(info.kp_proc.p_comm, name) == 0) {
        return 0;
    }

    return info.kp_eproc.e_ppid;

#else
    (void)pid;
    (void)name;
    return -1;
#endif
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s <name>\n", argv[0]);
        return 2;
    }

    const char *name = argv[1];

    // Walk the process tree from our parent upward.
    // On any error, assume the ancestor exists to avoid an infinite loop.
    pid_t pid = getppid();
    while (pid > 1) {
        pid = check_and_get_ppid(pid, name);
        if (pid <= 0) {
            // pid == 0: found; pid < 0: error (assume ancestor exists to be safe)
            return 0;
        }
    }
    return 1;
}
