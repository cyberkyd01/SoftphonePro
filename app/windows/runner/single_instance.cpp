#include "single_instance.h"

namespace {
constexpr wchar_t kMutexName[] = L"Local\\SoftphoneProSingleInstance";
constexpr wchar_t kWindowClass[] = L"FLUTTER_RUNNER_WIN32_WINDOW";
}  // namespace

SingleInstance::~SingleInstance() {
  if (mutex_) {
    ::CloseHandle(mutex_);
  }
}

bool SingleInstance::Acquire() {
  mutex_ = ::CreateMutexW(nullptr, FALSE, kMutexName);
  if (!mutex_) {
    return true;  // Cannot tell; better to run than to refuse to start.
  }
  return ::GetLastError() != ERROR_ALREADY_EXISTS;
}

void ForwardArgumentsToRunningInstance(const std::vector<std::string>& args) {
  HWND target = nullptr;
  for (int i = 0; i < 80 && !target; i++) {  // up to ~8 s
    target = ::FindWindowW(kWindowClass, kMainWindowTitle);
    if (!target) ::Sleep(100);
  }
  if (!target) return;

  std::string payload;
  bool only_minimized = true;
  for (const auto& a : args) {
    if (!payload.empty()) payload += '\n';
    payload += a;
    if (a != "--minimized") only_minimized = false;
  }
  // A plain re-launch (or one carrying a link) brings the window up; an
  // autostart's "--minimized" must not.
  const bool raise = args.empty() || !only_minimized;

  DWORD pid = 0;
  ::GetWindowThreadProcessId(target, &pid);
  if (raise) {
    ::AllowSetForegroundWindow(pid);
  }

  // An empty payload means "just bring the window to the front".
  if (args.empty()) payload = "--show";

  COPYDATASTRUCT cds;
  cds.dwData = kCopyDataCommandLine;
  cds.cbData = static_cast<DWORD>(payload.size());
  cds.lpData = const_cast<char*>(payload.data());
  DWORD_PTR ignored = 0;
  ::SendMessageTimeoutW(target, WM_COPYDATA, 0, reinterpret_cast<LPARAM>(&cds),
                        SMTO_ABORTIFHUNG, 5000, &ignored);
}

bool ReadCommandLinePayload(LPARAM lparam, std::string* out) {
  const auto* cds = reinterpret_cast<const COPYDATASTRUCT*>(lparam);
  if (!cds || cds->dwData != kCopyDataCommandLine) return false;
  if (cds->cbData > 0 && cds->lpData) {
    out->assign(static_cast<const char*>(cds->lpData), cds->cbData);
  } else {
    out->clear();
  }
  return true;
}
