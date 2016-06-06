 /* pknew0.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Ввод новой анкеты
 * RUN
        вызывается при вводе анкеты заемщика
 * CALLER
        pknew.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
   21.07.2003 nadejda - выделила собственно редактирование анкеты в pknew0.p - чтобы можно было
                             редактировать старую анкету для тех видов кредитов, где это разрешено,
                             и возвращаться в редактирование анкеты, если нечаянно вышли
   13.12.03 marinav - добавлен список критериев для кот допускается пустое значение. Надо сделать настройку
   11.03.04 isaev   - убрал возможность печати
   23.07.04 saltanat - Добавлена процедура проверки наличия транзакции и вывода суммы и назначения платежа ** procedure checktran **.
                       Также добавлена процедура заполнения переменной v-chtran для определения совпадения ключевых данных ** procedure checkkrit **.
   02.08.04 saltanat - Добавила проверку на вид кредита. Будет просить номер комиссии только если это Быстрые деньги.
   07.09.04 saltanat - исправила срок действия комиссии.
   09.09.04 kanat - добавил проверку на ввод РНН - он не должен быть равным РНН НК
   30.09.04 saltanat - Добавила проверку на наличие плат.карточки у клиента. И проставление признака в анкете.
   11.10.04 saltanat - При проверке номера транзакции комиссии учитывать Bank: pkanketa.bank = s-ourbnk.
   25.11.04 saltanat - Потребкредиты. Для критерия "Название организации" в случае невмешения всей
                                      строки выводиться др.окно с полным наименованием.
   13.12.04 saltanat - Попросили сделать исключение при изъятии комиссии для офицера u00055(Головлева).
   24.12.04 saltanat - Добавление баллов по плат.карточке перенесено из pkkritlib-a.
   30.03.05 saltanat - run pro_rnn. - Перенесено в отдельную подпроцедуру: pkcard( pkkritlib.p).
   13/05/2005 madiyar - изменили работу с pkkrit
   16/08/2005 madiyar - список исключений (логинов) по запросу номера транзакции - в sysc where sysc.sysc = "pknotr"
   19/08/2005 madiyar - выход по v-sta = 2 (черный список)
                        проверка транзакции только после номера документа
   22/11/2005 madiyar - в Актобе проводки по комиссии устаревают через 10 дней
   13/12/2005 madiyar - в Уральске выдаем БД военнослужащим, справочники в comm'е, поэтому пока прописываем жестко в программе
   06/01/2006 madiyar - в Актобе выдаем БД военнослужащим
   19.04.06 Natalya D. - добавила изменения для Подарочной карты (s-credtype = '9')
   03/05/2006 madiyar - оптимизировал поиск и проверку проводки комиссии за рассмотрение заявки
   03/10/2006 madiyar - в Талдыкоргане выдаем БД военнослужащим
   17/10/2006 madiyar - в Талдыкоргане военнослужащим без стажа рейтинг -10 
   19/10/2006 madiyar - в Талдыкоргане военнослужащим без стажа рейтинг -20 (прописано по умолчанию в справочнике, поэтому просто закомментил -10)
   25/10/2006 madiyar - перекомпиляция
   15/02/07 marinav - убрана проверка на проводку комиссии
   26/02/2007 madiyar - убрал ветки по рейтингу военнослужащих для филиалов
   02/03/2007 madiyar - подправил рейтинг по несовершеннолетним детям
   02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
   30/12/2009 galina - перекомпеляция
   31/12/2009 galina - перекомпеляция
   
*/

{global.i}
{pk.i}
{yes-no.i}
{rkorepfun.i}

def var v-chtran as integer extent 5.
def shared var v-chtrans as integer.
def shared var v-trnum as integer format "zzzzzzz9".
def shared var v-refresh as logi.

def shared var v-sta as inte init 0.
define variable s_rowid as rowid.
def var v-title as char init " АНКЕТА КЛИЕНТА ДЛЯ ОЦЕНКИ ПОТРЕБИТЕЛЬСКОГО КРЕДИТА ".
def var v-fl as inte.

def shared var hanket as handle.
def var s-ourbnk as char init ''.

find sysc where  sysc.sysc matches "ourbnk" no-lock no-error.
if avail sysc then s-ourbnk  = sysc.chval.


{jabrw.i
&start     = " def frame pkanket2
                       t-anket.value1  view-as editor size 25 by 4 label ' Данные анкеты'
                       t-anket.value2  view-as editor size 45 by 4 label ' Пров. данные'
                       t-anket.value3  view-as editor size 2  by 4 label 'Пр'
               with centered row 3 title 'Полное название организации'. "
&head      = "t-anket"
&headkey   = "kritcod"
&index     = "bankln"

&formname  = "pkanket"
&framename = "pkanket"
&frameparm = " "
&where     = " true "
&predisplay = " find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
                run defval.
                v-fl = 1. "
&addcon    = "false"
&deletecon = "false"
&postcreate = " "
&postupdate   = " find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
 run value(pkkrit.proc) in hanket (t-anket.kritcod).
 if (v-sta = 1 or v-sta = 2 or v-sta = 3)  then leave upper. run defval.
 if pkkrit.kritcod = 'joborg' and Length(t-anket.value2) > 25 then
 display t-anket.value1 t-anket.value2 t-anket.value3 with frame pkanket2.
 display pkkrit.kritname v-cod @ t-anket.value1 t-anket.value2 t-anket.value3 with frame pkanket.
 update t-anket.value3 with frame pkanket.
 if t-anket.value3 = '1' then do:
   if pkkrit.kritspr ne '' then do:
      if num-entries(pkkrit.kritspr) = 1 then find first bookcod where bookcod.bookcod = pkkrit.kritspr and bookcod.code = t-anket.value1 no-lock no-error.
      else find first bookcod where bookcod.bookcod = entry(integer(s-credtype),pkkrit.kritspr) and bookcod.code = t-anket.value1 no-lock no-error.
      if avail bookcod then do:
        t-anket.rating = int(bookcod.info[1]). t-anket.resdec[5] = int(bookcod.info[2]).
        /* if t-anket.kritcod = 'jobs' then run jobs_filial. */
      end.
      else do:
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
        if t-anket.kritcod = 'child16' then do:
            t-anket.rating = t-anket.rating * integer(t-anket.value1).
            t-anket.resdec[5] = t-anket.resdec[5] * integer(t-anket.value1).
        end.
      end.
   end.
   else do:
       t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])). 
       t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])). 
       if t-anket.kritcod = 'child16' then do:
           t-anket.rating = t-anket.rating * integer(t-anket.value1).
           t-anket.resdec[5] = t-anket.resdec[5] * integer(t-anket.value1).
       end.
   end.
 end.
 if (t-anket.value3 = '0' or t-anket.value1 = '' or trim(t-anket.value1) = '0') and lookup(t-anket.kritcod, 'apart1,mname,apart1s,mnames') = 0 then do:
     t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
     t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
 end.
/* if t-anket.credtype = '6' then do:*/
   run checkkrit. /*run checktran.*/ view frame pkanket.
   if v-refresh then do: v-refresh = no. next upper. end.
 pause 0. "
                 
&prechoose = " hide message. message 'F4 - выход'."

&postdisplay = " "

&display   = " pkkrit.kritname v-cod @ t-anket.value1 t-anket.value2 t-anket.value3  "
&update    = " t-anket.value1 "
&highlight = " t-anket.value1 "

&postkey   = "else if keyfunction(lastkey) = 'RETURN' and t-anket.kritcod = 'rnn' then do:
                      find first taxnk where taxnk.rnn = t-anket.value1 no-lock no-error.
                      if avail taxnk then do:
                      message 'Неверный РНН клиента (РНН НК)'.
                      return.
                      end.
              end."

&end = " hide message no-pause. "
}

procedure defval.
  find pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
  if pkkrit.kritspr = "" then v-cod = t-anket.value1.
  else do:
    if num-entries(pkkrit.kritspr) = 1 then find first bookcod where bookcod.bookcod = pkkrit.kritspr and bookcod.code = t-anket.value1 no-lock no-error.
    else find first bookcod where bookcod.bookcod = entry(integer(s-credtype),pkkrit.kritspr) and bookcod.code = t-anket.value1 no-lock no-error.
    if avail bookcod then v-cod = bookcod.name.
    else do:

      if num-entries(pkkrit.kritspr) = 1 then find first codfr where codfr.codfr = pkkrit.kritspr and codfr.code = t-anket.value1 no-lock no-error.
      else find first codfr where codfr.codfr = entry(integer(s-credtype),pkkrit.kritspr) and codfr.code = t-anket.value1 no-lock no-error.
      if avail codfr then v-cod = codfr.name[1].
                     else v-cod = t-anket.value1.
    end.
  end.
end.

procedure checkkrit.
/* */
CASE t-anket.kritcod:
  WHEN "rnn" THEN
    if t-anket.value3 = "1" then v-chtran[1] = 1.
                            else v-chtran[1] = 0.
  WHEN "lname" THEN
    if t-anket.value3 = "1" then v-chtran[2] = 1.
                            else v-chtran[2] = 0.
  WHEN "fname" THEN
    if t-anket.value3 = "1" then v-chtran[3] = 1.
                            else v-chtran[3] = 0.
  WHEN "mname" THEN
    if t-anket.value3 = "1" then v-chtran[4] = 1.
                            else v-chtran[4] = 0.
   WHEN "numpas" THEN
    if t-anket.value3 = "1" then v-chtran[5] = 1.
                            else v-chtran[5] = 0.
END CASE.
end.


/* **** Процедура проверки наличия транзакции и вывода суммы и назначения платежа **** */
procedure checktran.

/* для пользователей, указанных в справочнике, комиссия не должна сниматься */
find sysc where sysc.sysc = "pknotr" no-lock no-error.
if avail sysc then do:
  if lookup(g-ofc,sysc.chval) > 0 then return.
end.

/*find ofc where ofc.ofc = g-ofc no-lock no-error.
if not avail ofc or ofc.regno = 1003 then return.
*/
/* Проверка на необходимость работы процедуры */
if v-chtran[1] + v-chtran[2] + v-chtran[3] + v-chtran[4] + v-chtran[5] <> 5 or v-chtrans > 0 then return.

def var numacc as integer format "zzzzzzz9".
def var daysvalid as integer init 5.
def var log as integer init 0.

def frame pktran
          " ВВЕДИТЕ НОМЕР ТРАНЗАКЦИИ НА КОМИССИЮ ЗА ОБРАБОТКУ И ПРИЕМ АНКЕТЫ " skip(1)
          numacc no-label at 30 skip(1)
    with no-box centered row 4.

m:
do while log = 0:
  
  update numacc with frame pktran.
  
  if numacc = 0 then do:
        message " Номер транзакции не внесен ! " view-as alert-box.
  end.
  else do:

/* Будем выводить сумму и назначение платежа. */
  find first jl where jl.jh = numacc and jl.gl = 442900 no-lock no-error.
  if avail jl then do:
  find first jl where jl.jh = numacc and (jl.gl = 100100 or jl.gl = 100200) no-lock no-error.
  if avail jl then do:
     if (today - jl.jdt le daysvalid) then do:
        find first pkanketa where pkanketa.acc = numacc and pkanketa.bank = s-ourbnk use-index accid no-lock no-error.
        if avail pkanketa then message " Данный ордер уже был использован ! Комиссия не действительна ! " view-as alert-box.
        else do:
        message "СУММА ПЛАТЕЖА:       " jl.dam + jl.cam skip
                "НАЗНАЧЕНИЕ ПЛАТЕЖА:  " jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5] view-as alert-box.

        /* Передаем номер транзакции в переменной для занесения в таблицу pkanketa */
        v-trnum = numacc.
        
        if yes-no ('', ' Подтверждаете правильность данных ?') then do:
           v-chtrans = 1.
           leave m.
        end.
        else do:
           v-trnum = 0.
           next m.
        end.
        end.
     end.
     else
     message " Срок действия комиссии истек ! " view-as alert-box.
  end.
  else message " Комиссия не найдена ! " view-as alert-box.
  end.
  else message " Данный номер не является номером транзакции на комиссию ! " view-as alert-box.
  
  end.

end.

return.
end.
/*
procedure pro_rnn.

{con-crd.i}
find first card_status where card_status.rnn = t-anket.value1 and card_status.name matches "*OK*" no-lock no-error.
if avail card_status then do:
    t-anket.rating = t-anket.rating + 5.
    find t-anket where t-anket.kritcod = 'ak34' no-error.
         if avail t-anket then do:
            t-anket.value1 = '1'.
            t-anket.value3 = '1'.
            t-anket.value4 = '1'.
            display t-anket.value1 t-anket.value3 with frame pkanket.
         end.
    find t-anket where t-anket.kritcod = 'rnn' no-error.
    if avail t-anket then display t-anket.value1 t-anket.value2 t-anket.value3 with frame pkanket.
end.
if connected ("cards") then disconnect cards no-error.

end procedure.
*/

