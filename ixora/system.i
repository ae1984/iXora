/* system.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        29/09/2011 k.gitalov
 * BASES
        BANK
 * CHANGES
*/


/****************************************************************************************************************************/
function Version returns integer (input ClientIP as char).
  def var res as int init 0.
  def var data as char.
  def var buff as char.
  input through value("ssh  -q Administrator@" + ClientIP + " 'ver' ").
  repeat:
	import unformatted buff.
	data = data + buff.
  end.
  if index(data,"Windows XP") > 0 then res = 0.
  else res = 1.
  return res.
end function.
/****************************************************************************************************************************/
function IsFileExist returns log (input ClientIP as char).
  def var tmp as char.
  def var data as char.
  input through value("ssh  -q Administrator@" + ClientIP + " if exist 'c:\\windows\\system32\\crptprg.exe' echo YES ").
  repeat:
    import unformatted tmp.
    data = data + tmp.
  end.
  if index(data,"YES") > 0 then return true.
  else return false.
end function.
/****************************************************************************************************************************/
/* GetFilePid(ClientIP,"crpt.exe")*/
function GetFilePid returns char (input ClientIP as char, input fname as char).
  def var tmp as char.
  def var data as char.
  input through value("ssh  -q Administrator@" + ClientIP + " 'tasklist' ").
  repeat:
    import unformatted tmp.
    data = data + tmp.
  end.
  if index(data,fname) > 0 then do:
    data = trim(substr(data,index(data,fname) + length(fname) ,80)).
    return substr(data,1,index(data," ")) .
  end.
  else return "".
end function.
/****************************************************************************************************************************/
function StopProcPid returns log (input ClientIP as char,input pid as char).
  def var tmp as char.
  def var data as char.
  input through value("ssh  -q Administrator@" + ClientIP + " tskill " + pid ).
  repeat:
    import unformatted tmp.
    data = data + tmp.
  end.
  if data = "" then return true.
  else return false. /*что то случилось при остановке*/
end function.
/****************************************************************************************************************************/
function IsServiceExist returns log (input ClientIP as char,input port as char).
  DEFINE VARIABLE hSocket     AS HANDLE  NO-UNDO.
  CREATE SOCKET hSocket.
  hSocket:SET-SOCKET-OPTION("TCP-NODELAY", "FALSE" ).
  hSocket:CONNECT("-H " + ClientIP + " -S " + port) NO-ERROR.
  if not hSocket:CONNECTED() then return false.
  else do:
    hSocket:DISCONNECT() NO-ERROR.
    DELETE OBJECT hSocket.
    return true.
  end.
end function.
/****************************************************************************************************************************/
function GetXMLParamValue returns char (input ParamData as char,input ParamName as char).
  if ParamData = "" then return "".
  def var p-int1 as int.
  def var p-int2 as int.
  def var c-par1 as char.
  def var c-par2 as char.

  c-par1 = "<" + ParamName + ">".
  c-par2 = "</" + ParamName + ">".

  p-int1 = index(ParamData,c-par1) + length(c-par1).
  p-int2 = index(ParamData,c-par2).

  if p-int1 <> 0 and p-int2 <> 0 then return substr(ParamData,p-int1,p-int2 - p-int1).
  else return "".
end function.
/**************************************************************************************************/
/* ServiceStart(ClientIP,CRPTTools,crptsvr.exe)*/
procedure ServiceStart:
 def input param ClientIP as char.
 def input param SCname as char.
 def input param EXEname as char.
 def var Service as char.
 def var BUFF as char.
 hide message no-pause.
 message "Определение процесса...".
  input through value("ssh  -q Administrator@" + ClientIP + " 'SC start " + SCname + "' ").
  repeat:
	import unformatted BUFF.
	Service = Service + BUFF.
  end.
  Service = "".

  if index(Service,"The specified service does not exist") > 0 then run SRVinit(ClientIP,SCname,EXEname). /*Сервиса нет*/
  else do:
    /*Сервис есть, переустанавливаем*/
    hide message no-pause.
    message "Остановка процесса...".
    input through value("ssh  -q Administrator@" + ClientIP + " 'SC stop " + SCname + "' ").
    repeat:
	  import unformatted BUFF.
	  Service = Service + BUFF.
    end.
    Service = "".
    hide message no-pause.
    message "Удаление сервиса...".
    input through value("ssh  -q Administrator@" + ClientIP + " 'SC delete " + SCname + "' ").
    repeat:
	  import unformatted BUFF.
	  Service = Service + BUFF.
    end.
    Service = "".

    run SRVinit(ClientIP,SCname,EXEname).
  end.

end procedure.
/****************************************************************************************************************************/
procedure SRVinit:
  def input param ClientIP as char.
  def input param SCname as char.
  def input param EXEname as char.

  def var Service as char.
  def var BUFF as char.
  hide message no-pause.
  message "Инсталляция сервиса...".
     Service = "".
     input through value("scp -q /Certex/" + EXEname + " Administrator@" + ClientIP + "':C:\\WINDOWS\\system32\\" + EXEname + "' ").
     repeat:
      import unformatted BUFF.
      Service = Service + BUFF.
     end.
     if Service <> "" then do: message "Ошибка " Service "при копировании файла" view-as alert-box. return. end.
     Service = "".
     hide message no-pause.
     message "Регистрация процесса...".
     input through value("ssh  -q Administrator@" + ClientIP + " 'SC create " + SCname + " binPath= C:\\WINDOWS\\system32\\" + EXEname + " start= auto type= own type= interact' ").
     repeat:
      import unformatted BUFF.
      Service = Service + BUFF.
     end.
     Service = "".
     hide message no-pause.
     message "Запуск сервиса...".
     input through value("ssh  -q Administrator@" + ClientIP + " 'SC start " + SCname + "' ").
     repeat:
      import unformatted BUFF.
      Service = Service + BUFF.
     end.

     hide message no-pause.
     if index(Service,"START_PENDING") > 0 then message "Инсталляция завершена!".
     else message "Ошибка при запуске процесса".
     pause 3.
     hide message no-pause.
end procedure.
/****************************************************************************************************************************/
/****************************************************************************************************************************/
/****************************************************************************************************************************/
/****************************************************************************************************************************/
