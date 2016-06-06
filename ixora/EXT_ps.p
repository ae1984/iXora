/* EXT_ps.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Сервис по формированию промежуточных и итоговых выписок для Кар-Тел
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
        18.05.2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        26/07/2011 k.gitalov - Пустые выписки в dbf не формируются
        29/07/2011 k.gitalov - поставил интервал 59 секунд (если стартовал в 00:00 то отрабатывал 2 раза)
        06/12/2011 id00004 - изменил временной интервал формирования выписки (30 мин) согласно СЗ
        04.06.2013 dmitriy - ТЗ 1861. Изменил временной интервал формирования выписки на 10 мин
*/

{classes.i}

def var rcode as inte.
def var rdes as char.
def var cr_time as int.

def var StartTime as int init 32400. /* 9:00*/
def var EndTime as int init 68400.  /* 19:00*/
def var CurTime as int.


CurTime = time.

find first sysc where sysc.sysc = "EXT_ps" no-lock no-error.
if not avail sysc then do:
 /*message "Нет записи sysc! создаем" view-as alert-box.*/
 create sysc.
        sysc.sysc = "EXT_ps".
        sysc.des = "Сервис EXT_ps".
        sysc.daval = today.
        if CurTime >= StartTime and CurTime < EndTime then sysc.loval = true.
        else sysc.loval = false.
end.


/*
sysc.des = "CODE DESCRIPTION".
sysc.chval = "CHARVAL".
sysc.inval = 0.
sysc.deval = 0.0.
sysc.daval = today.
sysc.loval = true.
*/

/*
32400 9:00
36000 10:00
39600 11:00
43200 12:00
46800 13:00
50400 14:00
54000 15:00
57600 16:00
61200 17:00
64800 18:00
68400 19:00
*/

/*******************************************************************************************/
function SetStat returns log (input p-loval as log).
   find first sysc where sysc.sysc = "EXT_ps" exclusive-lock no-error.
   if avail sysc then do:
      sysc.loval = p-loval.
      return true.
   end.
   else return false.
end function.
/*******************************************************************************************/
function GetStat returns log ().
   find first sysc where sysc.sysc = "EXT_ps" no-lock no-error.
   if avail sysc then do:
      return sysc.loval.
   end.
   else return false.
end function.
/*******************************************************************************************/
function SaveLog returns log (input fCif as char , input fAcc as char , input fName as char , input ftime_cr as int , input ftime_post as int).
  create extract_his.
         extract_his.cif = fCif.
         extract_his.acc = fAcc.
         extract_his.ext_name = fName.
         extract_his.whn_cr = today.
         extract_his.time_cr = ftime_cr.
         extract_his.time_post = ftime_post.
  return true.
end function.
/*******************************************************************************************/
function CopyFile returns log (input fCif as char ,input fAcc as char , input fName as char , output fdes as char).
    def var v-result as char init "".
  /* ssh -i /home/id00205/.ssh/id_kartel  connect@172.16.2.10 */
   /* input through value ("scp -i /home/id00205/.ssh/id_kartel " + fName + " connect@172.16.2.10:/home/connect/" + fCif + "/" + fAcc + "/" + fName ). */
   /* /drbd/data/reports/extract  /data/reports/extract/ */
   /* input through value ("mv " + fName + " /data/reports/extract/" + fCif + "/" + fAcc + "/" + fName ). */

    def var ConnString as char.
    def var v as char.
    /*ConnString = "scp -i /home/id00205/.ssh/id_kartel " + fName + " connect@172.16.2.10:/home/connect/" + fCif + "/" + fAcc + "/" + fName.*/
    ConnString = "scp -i /home/superman/.ssh/id_kartel " + fName + " connect@172.16.2.10:/home/connect/" + fCif + "/" + fAcc + "/" + fName.
    /*копируем на внешний сервер*/
    input through value ( ConnString ).
    repeat:
      import unformatted v.
      v-result = v-result + v.
    end.
    if v-result <> "" then do:
        fdes =  fName + "\n Result= " + v-result + "\n ConnString= " + ConnString.
        run mail("id00205@metrocombank.kz", "info@metrocombank.kz", "Ошибка копирования на внешний сервер", fdes , "", "", "").
    end.

    v-result = "".
    v = "".
    input through value ("mv " + fName + " /drbd/data/reports/extract/" + fCif + fAcc + fName ).
    repeat:
      import unformatted v.
      v-result = v-result + v.
    end.
    if v-result <> "" then do:
        fdes =  "Ошибка перемещения " + fName + " " + v-result.
        run mail("id00205@metrocombank.kz", "info@metrocombank.kz", "Ошибка перемещения файла", fdes , "", "", "").
        return false.
    end.
    else do: fdes = fName. return true. end.
end function.
/*******************************************************************************************/

if CurTime >= StartTime and CurTime < EndTime and GetStat() = false then do: SetStat(true). /* message "Рабочее время!" view-as alert-box.*/ end.
if not GetStat() then do:  /* message "Не вовремя!" view-as alert-box. */ return. end. /*если false уходим*/


/*if not ((CurTime >= 32400 and CurTime <= 32459) or
   (CurTime >= 36000 and CurTime <= 36059) or
   (CurTime >= 39600 and CurTime <= 39659) or
   (CurTime >= 43200 and CurTime <= 43259) or
   (CurTime >= 46800 and CurTime <= 46859) or
   (CurTime >= 50400 and CurTime <= 50459) or
   (CurTime >= 54000 and CurTime <= 54059) or
   (CurTime >= 57600 and CurTime <= 57659) or
   (CurTime >= 61200 and CurTime <= 61259) or
   (CurTime >= 64800 and CurTime <= 64859) or
   (CurTime >= 68400 and CurTime <= 68459)) then return. */


if not ((CurTime >= 32400 and CurTime <= 32459) or
        (CurTime >= 33000 and CurTime <= 33059) or
        (CurTime >= 33600 and CurTime <= 33659) or
        (CurTime >= 34200 and CurTime <= 34259) or
        (CurTime >= 34800 and CurTime <= 34859) or
        (CurTime >= 35400 and CurTime <= 35459) or
        (CurTime >= 36000 and CurTime <= 36059) or
        (CurTime >= 36600 and CurTime <= 36659) or
        (CurTime >= 37200 and CurTime <= 37259) or
        (CurTime >= 37800 and CurTime <= 37859) or
        (CurTime >= 38400 and CurTime <= 38459) or
        (CurTime >= 39000 and CurTime <= 39059) or
        (CurTime >= 39600 and CurTime <= 39659) or
        (CurTime >= 40200 and CurTime <= 40259) or
        (CurTime >= 40800 and CurTime <= 40859) or
        (CurTime >= 41400 and CurTime <= 41459) or
        (CurTime >= 42000 and CurTime <= 42059) or
        (CurTime >= 42600 and CurTime <= 42659) or
        (CurTime >= 43200 and CurTime <= 43259) or
        (CurTime >= 43800 and CurTime <= 43859) or
        (CurTime >= 44400 and CurTime <= 44459) or
        (CurTime >= 45000 and CurTime <= 45059) or
        (CurTime >= 45600 and CurTime <= 45659) or
        (CurTime >= 46200 and CurTime <= 46259) or
        (CurTime >= 46800 and CurTime <= 46859) or
        (CurTime >= 47400 and CurTime <= 47459) or
        (CurTime >= 48000 and CurTime <= 48059) or
        (CurTime >= 48600 and CurTime <= 48659) or
        (CurTime >= 49200 and CurTime <= 49259) or
        (CurTime >= 49800 and CurTime <= 49859) or
        (CurTime >= 50400 and CurTime <= 50459) or
        (CurTime >= 51000 and CurTime <= 51059) or
        (CurTime >= 51600 and CurTime <= 51659) or
        (CurTime >= 52200 and CurTime <= 52229) or
        (CurTime >= 52800 and CurTime <= 52859) or
        (CurTime >= 53400 and CurTime <= 53459) or
        (CurTime >= 54000 and CurTime <= 54059) or
        (CurTime >= 54600 and CurTime <= 54659) or
        (CurTime >= 55200 and CurTime <= 55259) or
        (CurTime >= 55800 and CurTime <= 55859) or
        (CurTime >= 56400 and CurTime <= 56459) or
        (CurTime >= 57000 and CurTime <= 57059) or
        (CurTime >= 57600 and CurTime <= 57659) or
        (CurTime >= 58200 and CurTime <= 58259) or
        (CurTime >= 58800 and CurTime <= 58859) or
        (CurTime >= 59400 and CurTime <= 59459) or
        (CurTime >= 60000 and CurTime <= 60059) or
        (CurTime >= 60600 and CurTime <= 60659) or
        (CurTime >= 61200 and CurTime <= 61259) or
        (CurTime >= 61800 and CurTime <= 61859) or
        (CurTime >= 62400 and CurTime <= 62459) or
        (CurTime >= 63000 and CurTime <= 63059) or
        (CurTime >= 63600 and CurTime <= 63659) or
        (CurTime >= 64200 and CurTime <= 64259) or
        (CurTime >= 64800 and CurTime <= 64859) or
        (CurTime >= 65400 and CurTime <= 65459) or
        (CurTime >= 66000 and CurTime <= 66059) or
        (CurTime >= 66600 and CurTime <= 66659) or
        (CurTime >= 67200 and CurTime <= 67259) or
        (CurTime >= 67800 and CurTime <= 67859) or
        (CurTime >= 68400 and CurTime <= 68459))
 then return.

for each extract no-lock:
   cr_time = time.
   rdes = "".
   rcode = 0.

  case extract.note:

    when "MT940" then do:
     if CurTime >= EndTime then do:
       run ext940gen(extract.acc,output rcode, output rdes).
       run PostRun.
     end.
    end.

    when "DBF" then do:
       run extDBFgen(extract.acc,output rcode, output rdes).
       run PostRun.
    end.

    when "ALL" then do:
       run extDBFgen(extract.acc,output rcode, output rdes).
       run PostRun.
       if CurTime >= EndTime then do:
         cr_time = time.
         run ext940gen(extract.acc,output rcode, output rdes).
         run PostRun.
       end.
    end.

  end case.
end.

if CurTime >= EndTime then do:
  SetStat(false).
end.

procedure PostRun:
       if rcode <> 0 then do:
         run mail("id00205@metrocombank.kz", "info@metrocombank.kz", "Сообщение EXT_ps", rdes + "~n Код завершения - " + string(rcode) , "", "", "").
       end.
       else do:
         CopyFile( extract.cif , extract.acc , rdes , output rdes ).
         SaveLog( extract.cif , extract.acc , rdes , cr_time , time).
       end.
end procedure.

