object dm: Tdm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Left = 340
  Top = 123
  Height = 185
  Width = 215
  object IBEvents: TIBEvents
    AutoRegister = True
    Database = IBDatabase
    Events.Strings = (
      'req_sync')
    Registered = False
    OnEventAlert = IBEventsEventAlert
    OnError = IBEventsError
    Left = 16
    Top = 16
  end
  object IBDatabase: TIBDatabase
    DatabaseName = 'E:\src\blog\iblogis\BB3.FDB'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=UTF8')
    LoginPrompt = False
    DefaultTransaction = IBTransaction
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    Left = 80
    Top = 16
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = IBDatabase
    AutoStopAction = saNone
    Left = 144
    Top = 16
  end
  object IBSQL: TIBSQL
    Database = IBDatabase
    ParamCheck = True
    Transaction = IBTransaction
    Left = 80
    Top = 72
  end
end
