object AccesoBascula: TAccesoBascula
  OldCreateOrder = False
  Height = 150
  Width = 215
  object ComPort: TComPort
    BaudRate = br9600
    Port = 'COM1'#0' Tdx'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrDisable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    StoredProps = [spBasic]
    TriggersOnRxChar = True
    OnRxChar = ComPortRxChar
    Left = 104
    Top = 64
  end
  object Timer: TTimer
    Interval = 700
    Left = 40
    Top = 24
  end
end
