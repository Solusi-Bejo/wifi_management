/// Delay before the [attempt]-th consecutive reconnect: 2, 4, 8, 16 s, then
/// 30 s for every attempt after that.
Duration defaultWifiRetryDelay(int attempt) => attempt >= 5
    ? const Duration(seconds: 30)
    : Duration(seconds: 1 << (attempt < 1 ? 1 : attempt));
