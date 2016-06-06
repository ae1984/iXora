/* kdkkwho.p Электронное кредитное досье

 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Выбор присутствующих на кред комитете
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-
 * AUTHOR
        18.03.2004 marinav
 * CHANGES
        30/04/2004 madiar - работа с досье филиалов в ГБ
        18/05/2004 madiar - Исправил проблему с одновременным доступом к данным - теперь таблица лочится только в момент сохранения данных
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
    05/09/06   marinav - добавление индексов
*/


{global.i}
{kd.i}
{kdkrkom.f}

def var kdaffilcod as char.
def var kdaffilcod2 as char.

if s-kdlon = '' then return.

find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

define var v-cod as char.
define var v-sel as char.

 {kdkrvew.i}

if s-ourbank = kdlon.bank then do:
  kdaffilcod = '32'. kdaffilcod2 = '33'.
end.
else do:
  kdaffilcod = '42'. kdaffilcod2 = '43'.
end.

repeat:
  run sel ("Выбор :", 
           " 1. Председатель Кредитного Комитета | 2. Члены Кредитного комитета | 3. Выход ").
  v-sel = return-value.
  case v-sel:
    when "1" then do:
       run kdkk1.
    end.
    when "2" then do:
       run kdkk2.
    end.
    when "3" then return.
  end case.
end.



procedure kdkk1.

   define var v-kk as char.
   def var vans as logi.
   define var fl as inte.

form  skip(1) "ПРЕДСЕДАТЕЛЬ КРЕДИТНОГО КОМИТЕТА" at 10 skip(1)
       kdaffil.info[1]  no-label help "F2 - список для выбора" skip(1) 
       with 5 down overlay centered row 6 frame fr.


on help of kdaffil.info[1] in frame fr do:
   run h-codfr1('kdkom', kdaffil.name, output v-cod).
   kdaffil.info[1] = entry(1, v-cod).
   find first codfr where codfr.codfr = 'kdkom' and codfr.code = kdaffil.info[1] no-lock no-error.
   if avail codfr then kdaffil.info[1] = codfr.name[1] + ',' + codfr.name[2].
   displ kdaffil.info[1] with frame fr.
end.

   find first kdaffil where /*kdaffil.bank = s-ourbank and*/ 
                            kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = kdaffilcod 
                        and kdaffil.dat = kdlon.datkk no-lock no-error.
   if avail kdaffil and kdaffil.name ne '' then do:
      v-kk = kdaffil.name.

repeat:

{jabr.i 

  &start     =  " message 'F1 - список для выбора'. fl = 0. "
  &head      =  "kdaffil"
  &headkey   =  "code"
  &index     =  "cifnomc"
  &formname  =  "pksysc"
  &framename =  "kdkk1"
  &where     =  " /*kdaffil.bank = s-ourbank and*/ 
                        kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = kdaffilcod  "
  &addcon    =  "false"
  &deletecon =  "false"
  &prechoose =  " message 'F1 - список для выбора'. "
  &predisplay = " "
  &display   =  " kdaffil.info[1] "
  &highlight =  " kdaffil.info[1] "
  &postkey   =  " else if keyfunction(lastkey) = 'GO' then do:
                     run h-codfr1('kdkom', v-kk, output v-cod).
                     if keyfunction(lastkey) ne 'end-error' then do:
                        find first codfr where codfr.codfr = 'kdkom' and codfr.code = entry(1, v-cod) no-lock no-error.
                        kdaffil.info[1] = codfr.name[1] + ',' + codfr.name[2].
                        fl = 1.
                     end. next upper. 
                  end. "
  &end =        " hide frame kdkk1. "
}

 hide message. pause 0.
 if fl = 0 then leave.
 end.
   end.
end.



procedure kdkk2.
   define var v-kk as char.
   define var i as inte.
   def var vans as logi.
   define var fl as inte.

   find first kdaffil where /*kdaffil.bank = s-ourbank and*/ 
                        kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = kdaffilcod 
                        and kdaffil.dat = kdlon.datkk no-lock no-error.
   if avail kdaffil and kdaffil.name ne '' then do:
      v-kk = kdaffil.name.

      find first kdaffil where /*kdaffil.bank = s-ourbank and*/ 
                           kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = kdaffilcod2  no-lock no-error.
      if not avail kdaffil then do:
         run h-codfr1('kdkom', v-kk, output v-cod).
         if keyfunction(lastkey) eq "end-error" then return.
         do i = 1 to num-entries(v-cod):
            find first codfr where codfr.codfr = 'kdkom' and codfr.code = entry(i, v-cod) no-lock no-error.
            create kdaffil.
            assign kdaffil.bank = s-ourbank
                   kdaffil.code = kdaffilcod2 
                   kdaffil.kdcif = s-kdcif
                   kdaffil.kdlon = s-kdlon
                   kdaffil.info[1] = codfr.name[1] + ',' + codfr.name[2].
            find current kdaffil no-lock no-error.
         end.
      end.

repeat:

{jabr.i 

  &start     =  " message 'F1 - список для выбора'. fl = 0. "
  &head      =  "kdaffil"
  &headkey   =  "code"
  &index     =  "cifnomc"
  &formname  =  "pksysc"
  &framename =  "kdkk2"
  &where     =  " /*kdaffil.bank = s-ourbank and*/ 
                        kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = kdaffilcod2  "
  &addcon    =  "false"
  &deletecon =  "false"
  &prechoose =  " message 'F1 - список для выбора'. "
  &predisplay = " "
  &display   =  " kdaffil.info[1] "
  &highlight =  " kdaffil.info[1] "
  &postkey   =  " else if keyfunction(lastkey) = 'GO' then do:
                     run h-codfr1('kdkom', v-kk, output v-cod).
                     if keyfunction(lastkey) ne 'end-error' then do:
                        for each kdaffil where /*kdaffil.bank = s-ourbank and*/
                            kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and  kdaffil.code = kdaffilcod2 .
                            delete kdaffil.
                        end.
                        do i = 1 to num-entries(v-cod):
                              find first codfr where codfr.codfr = 'kdkom' and codfr.code = entry(i, v-cod) no-lock no-error.
                              create kdaffil.
                              assign kdaffil.bank = s-ourbank
                                     kdaffil.code = kdaffilcod2 
                                     kdaffil.kdcif = s-kdcif
                                     kdaffil.kdlon = s-kdlon
                                     kdaffil.info[1] = codfr.name[1] + ',' + codfr.name[2].
                         end.
                         fl = 1.
                     end. next upper. 
                  end. "
  &end =        " hide frame kdkk2. "
}

 hide message. pause 0.
 if fl = 0 then leave.
 end.
   end.
end.

