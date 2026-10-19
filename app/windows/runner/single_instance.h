#ifndef RUNNER_SINGLE_INSTANCE_H_
#define RUNNER_SINGLE_INSTANCE_H_

#include <windows.h>

#include <string>
#include <vector>

// Title of the main window; also used to find the running instance.
constexpr wchar_t kMainWindowTitle[] = L"SoftphonePro";
// COPYDATASTRUCT::dwData tag of a forwarded command line ("SPL1").
constexpr ULONG_PTR kCopyDataCommandLine = 0x53504C31;

// Named-mutex based single instance guard.
class SingleInstance {
 public:
  SingleInstance() = default;
  ~SingleInstance();
  SingleInstance(const SingleInstance&) = delete;
  SingleInstance& operator=(const SingleInstance&) = delete;

  // Returns true if this process is the first instance.
  bool Acquire();

 private:
  HANDLE mutex_ = nullptr;
};

// Sends |args| (UTF-8, newline separated) to the window of the running
// instance via WM_COPYDATA and lets it come to the foreground. Waits briefly
// if the first instance has not created its window yet.
void ForwardArgumentsToRunningInstance(const std::vector<std::string>& args);

// Decodes a WM_COPYDATA command-line payload; returns false if |lparam| is
// not one.
bool ReadCommandLinePayload(LPARAM lparam, std::string* out);

#endif  // RUNNER_SINGLE_INSTANCE_H_
