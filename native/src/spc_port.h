/* Tiny portability shim: threads, mutex, condvar, clocks. */
#ifndef SPC_PORT_H
#define SPC_PORT_H

#include <stdint.h>
#include <stddef.h>

#if defined(_WIN32)
#  define WIN32_LEAN_AND_MEAN
#  include <windows.h>
typedef CRITICAL_SECTION spc_mutex_t;
typedef CONDITION_VARIABLE spc_cond_t;
typedef HANDLE spc_thread_t;
#else
#  include <pthread.h>
typedef pthread_mutex_t spc_mutex_t;
typedef pthread_cond_t spc_cond_t;
typedef pthread_t spc_thread_t;
#endif

void spc_mutex_init(spc_mutex_t* m);   /* recursive */
void spc_mutex_destroy(spc_mutex_t* m);
void spc_mutex_lock(spc_mutex_t* m);
void spc_mutex_unlock(spc_mutex_t* m);
void spc_cond_init(spc_cond_t* c);
void spc_cond_destroy(spc_cond_t* c);
void spc_cond_signal(spc_cond_t* c);
void spc_cond_broadcast(spc_cond_t* c);
/* returns 0 when signalled, 1 on timeout */
int  spc_cond_timedwait(spc_cond_t* c, spc_mutex_t* m, int ms);
void spc_cond_wait(spc_cond_t* c, spc_mutex_t* m);
int  spc_thread_create(spc_thread_t* t, void (*fn)(void*), void* arg);
void spc_thread_join(spc_thread_t* t);
void spc_thread_detach(spc_thread_t* t);
int64_t spc_now_ms(void);      /* unix epoch ms */
int64_t spc_mono_ms(void);     /* monotonic ms */
void spc_sleep_ms(int ms);
/* runs fn exactly once even if called concurrently; state must be a zero-initialised static */
void spc_once(volatile long* state, void (*fn)(void));

#endif
