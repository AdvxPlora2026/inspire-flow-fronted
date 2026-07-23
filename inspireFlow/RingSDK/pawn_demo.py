"""PAWN 戒指交互实例程序

演示流程：
1. 扫描并连接 Zilo Whisper 戒指
2. 读取系统信息（固件、电量等）
3. 启用自动校时
4. 监听按键事件（双击唤醒 PAWN Agent）
5. 监听手势事件（前旋=确认 / 后旋=取消 / 挥手=标记）
6. 可选：实时 IMU 数据

注意：音频采集由 viaim 耳机完成，戒指不负责录音。
"""

import asyncio
import sys
from pathlib import Path

# 将 ringSDK 目录加入 Python 路径
RING_SDK_DIR = Path(__file__).resolve().parent / "ringSDK"
sys.path.insert(0, str(RING_SDK_DIR))

import ring_sound as sdk  # noqa: E402


# ---------- 配置 ----------
RING_MAC_ADDRESS = "5CC790BE-E746-ABF8-25B9-29745F56507A"  # 替换为你的戒指 MAC 地址
SCAN_TIMEOUT = 10.0
EVENT_TIMEOUT = 300.0  # 事件等待超时（秒）


# ---------- 主程序 ----------
async def main():
    try:
        # ===== 步骤 1：扫描戒指 =====
        print("=" * 50)
        print("  PAWN Agent - 戒指交互演示")
        print("=" * 50)

        print(f"\n[1/4] 扫描戒指 (MAC: {RING_MAC_ADDRESS})...")
        devices = await sdk.scan_rings(
            address=RING_MAC_ADDRESS,
            timeout_s=SCAN_TIMEOUT,
        )

        target_addr = RING_MAC_ADDRESS
        if devices:
            print(f"  发现 {len(devices)} 个匹配设备:")
            for d in devices:
                print(f"    - {d.name or '(无名称)'}  [{d.address}]  RSSI: {d.rssi}")
            target_addr = devices[0].address
        else:
            print("  未扫描到设备，尝试直接连接...")

        # ===== 步骤 2：连接并读取系统信息 =====
        print(f"\n[2/4] 连接戒指并读取系统信息...")

        async with sdk.connect_ring(address=target_addr) as ring:
            info = await sdk.get_system_info(ring)
            print(f"  固件版本 : {info.firmware_version}")
            print(f"  设备型号 : {info.model}")
            print(f"  序列号   : {info.sn}")
            print(f"  电量     : {info.battery_percent}% "
                  f"{'(充电中)' if info.battery_charging else '(未充电)'}")
            print(f"  存储     : {info.audio_storage_available}/{info.audio_storage_total} bytes")

            # ===== 步骤 3：启用自动校时 =====
            sdk.enable_time_sync(ring)
            print(f"\n[3/4] 自动校时已启用")

            # ===== 步骤 4：事件循环 =====
            print(f"\n[4/4] 开始监听戒指事件...")
            print("  ┌─────────────────────────────────────────┐")
            print("  │ 双击按键 → 唤醒 PAWN Agent             │")
            print("  │ 前旋手势 → 确认 (Confirm)              │")
            print("  │ 后旋手势 → 取消 (Cancel)               │")
            print("  │ 挥手手势 → 标记隐私级别 (Mark)          │")
            print("  │ Ctrl+C    → 退出                       │")
            print("  └─────────────────────────────────────────┘")

            await event_loop(ring)

    except sdk.TransportError as e:
        print(f"\n  [错误] BLE 传输失败: {e}")
        print("  请检查：蓝牙是否开启、戒指是否在附近、MAC 地址是否正确")
    except sdk.TimeoutError as e:
        print(f"\n  [错误] 操作超时: {e}")
    except sdk.DeviceError as e:
        print(f"\n  [错误] 设备返回错误码 {e.error_code}: {e}")
    except KeyboardInterrupt:
        print("\n\n  用户中断")


async def event_loop(ring: sdk.RingSoundClient):
    """主事件循环：并发监听按键和手势事件"""

    stop_event = asyncio.Event()
    event_count = {"wake": 0, "confirm": 0, "cancel": 0, "mark": 0}

    async def listen_keys():
        """监听双击按键 → 唤醒 PAWN"""
        while not stop_event.is_set():
            try:
                event = await sdk.wait_sensor_key_double_press_event(
                    ring,
                    timeout_s=EVENT_TIMEOUT,
                )
                event_count["wake"] += 1
                print(f"\n  🔔 双击按键 #{event_count['wake']} → 唤醒 PAWN Agent!")
                print(f"     时间戳: {event.timestamp_ms} ms")
                print(f"     → 触发 viaim 耳机开始语音采集...")

            except sdk.TimeoutError:
                continue
            except asyncio.CancelledError:
                break
            except sdk.RingSoundError as e:
                print(f"  [按键监听错误] {e}")
                await asyncio.sleep(1)

    async def listen_gestures():
        """监听手势事件"""
        while not stop_event.is_set():
            try:
                event = await sdk.wait_sensor_gesture_event(
                    ring,
                    timeout_s=EVENT_TIMEOUT,
                )
                gid = event.gesture_id
                name = sdk.sensor_gesture_name(gid)

                if gid == sdk.SensorGestureId.IDLE:
                    continue

                elif gid == sdk.SensorGestureId.ROTATE_FRONT:
                    event_count["confirm"] += 1
                    print(f"\n  前旋 #{event_count['confirm']} → 确认操作 "
                          f"(ts={event.timestamp_ms}ms)")

                elif gid == sdk.SensorGestureId.ROTATE_BACK:
                    event_count["cancel"] += 1
                    print(f"\n  后旋 #{event_count['cancel']} → 取消操作 "
                          f"(ts={event.timestamp_ms}ms)")

                elif gid == sdk.SensorGestureId.WAVE:
                    event_count["mark"] += 1
                    print(f"\n  挥手 #{event_count['mark']} → 标记隐私级别 "
                          f"(ts={event.timestamp_ms}ms)")

                else:
                    print(f"\n  手势: {name} (id={gid})")

            except sdk.TimeoutError:
                continue
            except asyncio.CancelledError:
                break
            except sdk.RingSoundError as e:
                print(f"  [手势监听错误] {e}")
                await asyncio.sleep(1)

    # 并发运行
    try:
        async with asyncio.TaskGroup() as tg:
            key_task = tg.create_task(listen_keys())
            gesture_task = tg.create_task(listen_gestures())

            # 等待键盘中断后退出
            await asyncio.get_event_loop().run_in_executor(
                None, lambda: sys.stdin.read(1)
            )

            stop_event.set()
            key_task.cancel()
            gesture_task.cancel()

    except* asyncio.CancelledError:
        stop_event.set()
    except* KeyboardInterrupt:
        stop_event.set()
    except* Exception as eg:
        for exc in eg.exceptions:
            if not isinstance(exc, (asyncio.CancelledError, KeyboardInterrupt)):
                print(f"  [事件循环异常] {exc}")

    print(f"\n  事件统计: 唤醒={event_count['wake']} "
          f"确认={event_count['confirm']} "
          f"取消={event_count['cancel']} "
          f"标记={event_count['mark']}")


# ---------- IMU 模式演示 ----------
async def imu_demo():
    """演示 IMU 数据读取（需先按键单击切换到手勢模式）"""
    print("=" * 50)
    print("  PAWN Agent - IMU 数据演示")
    print("=" * 50)

    async with sdk.connect_ring(address=RING_MAC_ADDRESS) as ring:
        print("\n请单击戒指按键，切换到手势模式...")
        try:
            press = await sdk.wait_sensor_key_single_press_event(ring, timeout_s=30.0)
            print(f"  检测到单击 (ts={press.timestamp_ms}ms)，尝试启动 IMU 上报...")
        except sdk.TimeoutError:
            print("  未检测到单击，直接尝试启动 IMU 上报...")

        try:
            start_info = await sdk.start_sensor_report(ring)
            print(f"  IMU 上报已启动: 采样率={start_info.sample_rate_hz}Hz, "
                  f"accel={start_info.accel_range_g}g, "
                  f"gyro={start_info.gyro_range_dps}dps")
        except sdk.DeviceError as e:
            print(f"  启动失败: {e} (可能戒指不在手势模式)")
            return

        print("\n读取 IMU 数据（Ctrl+C 停止）...")
        count = 0
        try:
            while True:
                batch = await sdk.wait_sensor_data(ring, timeout_s=5.0)
                count += 1
                for sample in batch.samples:
                    print(
                        f"  [{count}] ts={sample.timestamp_ms}ms | "
                        f"accel=({sample.accel_x:>6}, {sample.accel_y:>6}, {sample.accel_z:>6}) | "
                        f"gyro=({sample.gyro_x:>6}, {sample.gyro_y:>6}, {sample.gyro_z:>6})"
                    )
                if count >= 50:
                    print("\n已达 50 批次，停止。")
                    break
        except KeyboardInterrupt:
            pass
        finally:
            await sdk.stop_sensor_report(ring)
            print("  IMU 上报已停止")


# ---------- 扫描模式 ----------
async def scan_only():
    """仅扫描模式"""
    print(f"扫描附近戒指设备 (超时: {SCAN_TIMEOUT}s)...")
    devices = await sdk.scan_rings(timeout_s=SCAN_TIMEOUT)
    if devices:
        print(f"\n发现 {len(devices)} 个设备:")
        for d in devices:
            print(f"  {d.name or '(无名称)'}  [{d.address}]  RSSI: {d.rssi}")
    else:
        print("\n未发现任何设备")


# ---------- 入口 ----------
if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="PAWN Agent 戒指交互演示")
    parser.add_argument(
        "--address", "-a",
        default=RING_MAC_ADDRESS,
        help=f"戒指 MAC 地址 (默认: {RING_MAC_ADDRESS})",
    )
    parser.add_argument(
        "--imu", action="store_true",
        help="运行 IMU 数据演示模式",
    )
    parser.add_argument(
        "--scan-only", action="store_true",
        help="仅扫描附近戒指设备",
    )

    args = parser.parse_args()
    RING_MAC_ADDRESS = args.address

    if args.scan_only:
        asyncio.run(scan_only())
    elif args.imu:
        asyncio.run(imu_demo())
    else:
        asyncio.run(main())
