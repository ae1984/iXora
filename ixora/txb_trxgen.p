/* txb_trxgen.p
 * MODULE
        Для формирования проводок на TXB
        Запускать эту программу!!!
 * DESCRIPTION
        Соник-сервис для проверки данных клиента ИБФЛ
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
        13/05/2013 madiyar
 * BASES
        COMM TXB
 * CHANGES
*/

{xmlParser.i}

def input parameter trxcode as char.
def input parameter vdel as char.
def input parameter vparam as char.
def input parameter vsub as char.
def input parameter vref as char.
def input parameter vsts as int.  /*статус штампа 0 - 6*/

def output parameter rcode as inte.
def output parameter rdes as char.
def input-output parameter vjh as inte.


define variable txb_path as character.
define variable v-bank as character no-undo.
define variable buff as character init "".
define variable u_ret as character init "".


find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   rcode = 200.
   rdes = "Отсутствует переменная ourbnk!!!".
   return.
end.
v-bank = trim(sysc.chval).

find first comm.txb where comm.txb.bank = v-bank and comm.txb.consolid no-lock no-error.
if available comm.txb then txb_path = replace(comm.txb.path,'/data/','/data/b').  
else do:
   rcode = 300.
   rdes = "Не найден путь к базе данных!!!".
   return. 
end.    

vparam = replace(vparam,"("," ").
vparam = replace(vparam,")"," ").
vparam = replace(vparam," ","_").    

 
message "txb_trxgen-> " + txb_path + " " + trxcode + " " + vdel + " " + vparam + " " + vsub + " " + vref + " " + string(vsts) + " " + string(vjh).
                
input through value("txb_trxgen " + txb_path + " " + trxcode + " " + vdel + " " + vparam + " " + vsub + " " + vref + " " + string(vsts) + " " + string(vjh)) .
repeat:
    import unformatted buff.
    u_ret = u_ret + buff.
end.

message u_ret.

  if GetParamValueOne(u_ret,"Rcode") <> "" then do:
     rcode = integer(GetParamValueOne(u_ret,"Rcode")).
     rdes = GetParamValueOne(u_ret,"Rdes"). 
  end.
  else do:
     if GetParamValueOne(u_ret,"Trx") <> "" then vjh = integer(GetParamValueOne(u_ret,"Trx")).
     else do:
       rcode = 400.
       rdes = "Ошибка определения номера проводки!".  
     end.     
  end.    
     

