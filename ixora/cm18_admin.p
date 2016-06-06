/* cm18_admin.p
 * MODULE
        Название модуля
 * DESCRIPTION
        программа администрирования ЭК
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
        15/09/2012 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        19/09/2012 k.gitalov перекомпиляция
*/

{classes.i}



def var v-dispensedAmt as deci.
def var v-acceptedAmt as deci.
def var v-Amount as decimal extent 10.
def var pos as int init 0.
def var rez as log.
def var oper as char.
def var v-crc as char.
def var v-t as char.
def var v-safe as char.
def var stname as char.

def var ClientIP as char.
input through askhost.
import ClientIP.
input close.


/***********************************************************************************************************/
function GetCRCid returns int (input currency as char).
  def var id as int.
  def buffer b-crc for crc.
   find b-crc where b-crc.code = currency no-lock no-error.
   if avail b-crc then do:
     id = b-crc.crc.
   end.
   else id = 0.
  return id.
end function.
/***********************************************************************************************************/
function GetAdmName returns char ( input st_val as char ):
 def var STLIST as char init "ST00770.metrobank.kz,ST00848.metrobank.kz,ST33333.metrobank.kz,ST55555.metrobank.kz,ST99999.metrobank.kz,st00518.metrobank.kz".
 def var USRLIST as char format "x(25)" extent 6 init  ["id00787","id00205","id00700","id00640","id00477","id00800"].
   if st_val = "" then return "".
   return  USRLIST[LOOKUP(st_val , STLIST)].
end function.
/***********************************************************************************************************/

if GetAdmName(ClientIP) <> g-ofc or Base:g-fname <> "EKADM" then do:
   message "Запрещено запускать эту программу!" view-as alert-box.
   quit.
end.

def var summ as deci no-undo.

def new shared var v-safe_list as char.
for each cslist no-lock:
 v-safe_list = v-safe_list + cslist.nomer + "|".
end.
v-safe_list = substr(v-safe_list,1,length(v-safe_list) - 1).

 REPEAT on  ENDKEY UNDO  , leave :
        CASE pos:
          WHEN 0 THEN
          DO:
            oper = "".
            run sel1("Операции","Состояние сейфа|Пересчет|Выдача наличных|Прием наличных|Инкассация|Рестарт сервиса|Синхронизация|Выход").
            oper = return-value.
            IF keyfunction(lastkey) = "END-ERROR" then do: oper="". end.
            case oper:
              when "Состояние сейфа" then do:  pos = 1. end.
              when "Пересчет"        then do:  pos = 2. end.
              when "Выдача наличных" then do:  pos = 3. end.
              when "Прием наличных"  then do:  pos = 4. end.
              when "Инкассация"      then do:  pos = 5. end.
              when "Рестарт сервиса"         then do:  pos = 6. end.
              when "Синхронизация"   then do:  pos = 7. end.
              otherwise do:
              pos = 8.
              end.
            end case.
          END.
          WHEN 1 THEN  /*Состояние сейфа*/
          DO:
            run smart_adm(g-ofc,0,1,1,0,output v-dispensedAmt,output v-acceptedAmt, input-output v-Amount, output rez).
            pos = 0.
          END.
           WHEN 2 THEN /*Пересчет*/
          DO:
            run smart_adm(g-ofc,0,2,1,0,output v-dispensedAmt,output v-acceptedAmt, input-output v-Amount, output rez).
            pos = 0.
          END.
          WHEN 3 THEN  /*Выдача наличных*/
          DO:
            v-crc = "".
            run sel1("Выберите валюту","KZT|USD|EUR|RUB").
            v-crc = return-value.
            summ = 0.
            update summ label 'Сумма ' format '->>>>>>>>>>>9.99' skip
            with side-labels row 18 centered frame dat title "ВЫДАЧА НАЛИЧНЫХ".
            hide frame dat.
            run smart_adm(g-ofc,11111 ,3,GetCRCid(v-crc),summ,output v-dispensedAmt,output v-acceptedAmt, input-output v-Amount, output rez).
            pos = 0.
          END.
          WHEN 4 THEN  /*Прием наличных*/
          DO:
            v-crc = "".
            run sel1("Выберите валюту","KZT|USD|EUR|RUB").
            v-crc = return-value.
            summ = 0.
            update summ label 'Сумма ' format '->>>>>>>>>>>9.99' skip
            with side-labels row 18 centered frame dat title "ПРИЕМ НАЛИЧНЫХ".
            hide frame dat.
            run smart_adm(g-ofc,22222 ,4,GetCRCid(v-crc),summ,output v-dispensedAmt,output v-acceptedAmt, input-output v-Amount, output rez).
            pos = 0.
          END.
          WHEN 5 THEN  /*Инкассация*/
          DO:
            v-safe = "".
            run sel1("Сейфы",v-safe_list ).
            v-safe = return-value.
            run cm18_inkass(v-safe).
            pos = 0.
          END.
          WHEN 6 THEN  /*Рестарт*/
          DO:
            update stname label 'Компьютер '  skip
            with side-labels row 18 centered frame comp title "КОНЕЧНЫЙ КОМПЬЮТЕР".
            hide frame comp.
            run cm18_restart(stname).
            pos = 0.
          END.
          WHEN 7 THEN  /*Синхронизация*/
          DO:
            v-Amount[1] = 0.
            v-Amount[2] = 0.
            v-Amount[3] = 0.
            v-Amount[4] = 0.
            run smart_adm(g-ofc,0,5,1,0,output v-dispensedAmt,output v-acceptedAmt, input-output v-Amount, output rez).
            pos = 0.
          END.
          WHEN 8 THEN /* Выход */
          DO:
            run yn("","Выйти из программы?","","", output rez).
            if rez then  LEAVE.
            else do:
             pos = 0.
            end.
          END.
        END CASE.
 END.



