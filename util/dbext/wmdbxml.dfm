object WebModule1: TWebModule1
  OldCreateOrder = False
  OnCreate = WebModuleCreate
  OnDestroy = WebModuleDestroy
  Actions = <
    item
      Default = True
      Name = 'waDefault'
      OnAction = WebModule1waDefaultAction
    end
    item
      Name = 'waInfo'
      PathInfo = '/info'
      OnAction = WebModule1waInfoAction
    end>
  Height = 171
  Width = 229
end
