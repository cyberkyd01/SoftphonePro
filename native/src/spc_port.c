#include "spc_port.h"
#include <stdlib.h>
#include <time.h>
#include <errno.h>

#if defined(_WIN32)

void spc_mutex_init(spc_mutex_t* m) { InitializeCriticalSection(m); }
void spc_mutex_destroy(spc_mutex_t* m) { DeleteCriticalSection(m); }
void spc_mutex_lock(spc_mutex_t* m) { EnterCriticalSection(m); }
void spc_mutex_unlock(spc_mutex_t* m) { LeaveCriticalSection(m); }
void spc_cond_init(spc_cond_t* c) { InitializeConditionVariable(c); }
void spc_cond_destroy(spc_cond_t* c) { (void)c; }
void spc_cond_signal(spc_cond_t* c) { WakeConditionVariable(c); }
void spc_cond_broadcast(spc_cond_t* c) { WakeAllConditionVariable(c); }
int spc_cond_timedwait(spc_cond_t* c, spc_mutex_t* m, int ms)
{
    if (ms < 0) ms = 0;
    return SleepConditionVariableCS(c, m, (DWORD)ms) ? 0 : 1;
}
void spc_cond_wait(spc_cond_t* c, spc_mutex_t* m) { SleepConditionVariableCS(c, m, INFINITE); }

typedef struct { void (*fn)(void*); void* arg; } thr_start;
static DWORD WINAPI thr_main(LPVOID p)
{
    thr_start s = *(thr_start*)p;
    free(p);
    s.fn(s.arg);
    return 0;
}
int spc_thread_create(spc_thread_t* t, void (*fn)(void*), void* arg)
{
    thr_start* s = (thr_start*)malloc(sizeof(*s));
    if (!s) return -1;
    s->fn = fn; s->arg = arg;
    *t = CreateThread(NULL, 0, thr_main, s, 0, NULL);
    if (!*t) { free(s); return -1; }
    return 0;
}
void spc_thread_join(spc_thread_t* t)
{
    if (*t) { WaitForSingleObject(*t, INFINITE); CloseHandle(*t); *t = NULL; }
}
int64_t spc_now_ms(void)
{
    FILETIME ft; ULARGE_INTEGER u;
    GetSystemTimeAsFileTime(&ft);
    u.LowPart = ft.dwLowDateTime; u.HighPart = ft.dwHighDateTime;
    return (int64_t)((u.QuadPart - 116444736000000000ULL) / 10000ULL);
}
int64_t spc_mono_ms(void) { return (int64_t)GetTickCount64(); }
void spc_sleep_ms(int ms) { Sleep((DWORD)ms); }

#else

void spc_mutex_init(spc_mutex_t* m)
{
    pthread_mutexattr_t a;
    pthread_mutexattr_init(&a);
    pthread_mutexattr_settype(&a, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(m, &a);
    pthread_mutexattr_destroy(&a);
}
void spc_mutex_destroy(spc_mutex_t* m) { pthread_mutex_destroy(m); }
void spc_mutex_lock(spc_mutex_t* m) { pthread_mutex_lock(m); }
void spc_mutex_unlock(spc_mutex_t* m) { pthread_mutex_unlock(m); }
void spc_cond_init(spc_cond_t* c) { pthread_cond_init(c, NULL); }
void spc_cond_destroy(spc_cond_t* c) { pthread_cond_destroy(c); }
void spc_cond_signal(spc_cond_t* c) { pthread_cond_signal(c); }
void spc_cond_broadcast(spc_cond_t* c) { pthread_cond_broadcast(c); }
void spc_cond_wait(spc_cond_t* c, spc_mutex_t* m) { pthread_cond_wait(c, m); }
int spc_cond_timedwait(spc_cond_t* c, spc_mutex_t* m, int ms)
{
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    if (ms < 0) ms = 0;
    ts.tv_sec += ms / 1000;
    ts.tv_nsec += (long)(ms % 1000) * 1000000L;
    if (ts.tv_nsec >= 1000000000L) { ts.tv_sec++; ts.tv_nsec -= 1000000000L; }
    return pthread_cond_timedwait(c, m, &ts) == ETIMEDOUT ? 1 : 0;
}

typedef struct { void (*fn)(void*); void* arg; } thr_start;
static void* thr_main(void* p)
{
    thr_start s = *(thr_start*)p;
    free(p);
    s.fn(s.arg);
    return NULL;
}
int spc_thread_create(spc_thread_t* t, void (*fn)(void*), void* arg)
{
    thr_start* s = (thr_start*)malloc(sizeof(*s));
    if (!s) return -1;
    s->fn = fn; s->arg = arg;
    if (pthread_create(t, NULL, thr_main, s) != 0) { free(s); return -1; }
    return 0;
}
void spc_thread_join(spc_thread_t* t) { pthread_join(*t, NULL); }
int64_t spc_now_ms(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    return (int64_t)ts.tv_sec * 1000 + ts.tv_nsec / 1000000;
}
int64_t spc_mono_ms(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (int64_t)ts.tv_sec * 1000 + ts.tv_nsec / 1000000;
}
void spc_sleep_ms(int ms)
{
    struct timespec ts;
    ts.tv_sec = ms / 1000; ts.tv_nsec = (long)(ms % 1000) * 1000000L;
    nanosleep(&ts, NULL);
}
#endif
