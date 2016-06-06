/* pkkritlib.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Библиотека процедур проверки критериев анкеты
 * RUN
        вызывается при вводе анкеты заемщика из всех критериев
        объявлена в анкете persistent, параметры в каждой процедуре свои
 * CALLER
        pknew0.p
 * SCRIPT

 * INHERIT

 * MENU
        4-x-1
 * AUTHOR
        ..         marinav
 * CHANGES
        26.02.2003 nadejda - добавлена проверка в АКИ pkakires
        01.04.2003 nadejda - добавлена проверка Черного списка pkblacklst
        01.05.2003 marinav - добавлена проверка кредитного лимита для карточек pklim
        25.06.2003 nadejda - при обработке критерия krlim в pklim изменена запись кода кредитного лимита на сами данные кредитного лимита
        26.06.2003 nadejda - перенесла из pknew.p в процедуру обработки СИКа вопрос на посылку запроса в ГЦВП
                           - добавила в большинство процедур возможность поиска данных не только клиента, но и его супруга
        10.07.2003 marinav - проверка на непогашенный кредит по всем типам кредитов
                             проверка на совпадение суммы из ГЦВП с анкетной
        16.07.2003 nadejda - обработка настройки искать/не искать поданные ранее анкеты для отказа в процедуре pkrnn
        05.08.2003 marinav - автоматическое заполнение поля gcvpsum из ответа ГЦВП
        07.08.2003 nadejda - добавлена обработка наличия ссудных счетов в другом филиале - пока просто выход из анкеты
        19/08/2003 marinav - Добавлен учет прежней фамилии при запросе в ГЦВП
        09.10.03   marinav - вынесение заявки на кредитный комитет
        11.11.2003 marinav - запрет на повторный запрос в ГЦВП. Разрешить только если файл ответа пустой
        13.11.2003 marinav - запись всех запросов в ГЦВП в специальную таблицу
        15.11.2003 nadejda - при поиске РНН не учитываются те, которые кассиры ввели вручную - только загруженные из НК
        24.11.2003 nadejda - при поиске РНН воинской части было неверное проставление рейтинга - только 0, сделала поиск по pkkrit
        25.12.2003 nadejda - вызов программы анализа ответа ГЦВП pkanlgcvp.p
        11.01.2004 nadejda - процедура pkstage - рейтинг за стаж работы определяем по внесенным данным (ТЗ 679)
        16.01.2004 nadejda - отправитель письма по эл.почте изменен на общий адрес abpk@texakabank.kz
        25.02.2004 nadejda - обработка критерия siktwo - для СИКов, где две фамилии указаны
        12.05.2004 tsoy    - обработка критерия pkclnkorp  для проверки РНН организации если наш клиент то yes иначе no
        07/06/2004 madiyar - на случай наличия более одного cif-а у одного клиента - в процедуре pkacc1 открытые текущие счета по ТКБ
                             ищутся по всем cif-ам.
        07/06/2004 madiyar - в связи с добавлением нового критерия "nedvauto" (обрабатывается автоматически) добавлена процедура pknedvauto
        14.09.2004 saltanat - при проверке рнн дополнительно ищем рнн в базе BWX. если по данному РНН в таблице карточек есть запись
                              и у клиента активированная карта, то рейтинг увеличиваем на 5.
        20.09.2004 saltanat - включила дисконект базы Cards.
        22/09/2004 madiyar - если выдан кредит в другом филиале банка - проверяем погашен или нет, и если нет - не разрешаем выдавать новый
        13/10/2004 madiyar - если уже есть выданный кредит - проверяется, погашен он или нет по уровням 1,7,13,14
        15/10/2004 saltanat - в выводе ГЦВП-ответа: для карточек справочник "Категория должности" - "jobs1", для всех остальных - "jobs".
                              Если критерий отсутствует - передается "".
        17/11/2004 madiyar - обработчик pkcomment для замечаний менеджера
        19/11/2004 madiyar - pkrnn - если у клиента есть карточка то в pkanketh с кодом "ak34" (Платежная карта ТКБ) в value1 прописываем "1"
        25.11.2004 saltanat - в процедуре pknamjob увеличила размерность для поля "Название организации"
        10/12/2004 madiyar - проверка на отказ в течение 90 дней до регистрации текущей анкеты - не совсем корректно работала, исправил
        15.12.2004 saltanat - изменила выборку наличия плат.карт.
        24.12.2004 saltanat - убрала проверку и увеличение баллов при плат.карточке
        30.12.2004 saltanat - Проверка наличия кредита по всем базам
        18/02/2005 madiyar - в процедуре pkfam1 - кроме "00,02" (холост,в разводе) добавил "03" (вдова/вдовец)
        23/02/2005 madiyar - изменил поиск депозита клиента в ТКВ
        30.03.2005 saltanat - Создала процедуру pkcard, для учета рейтинга по плат.карт. Техакабанка.
        18/04/2005 madiyar - запрос в ЦИС теперь работает у всех менеджеров
        05/05/2005 madiyar - добавил изменение рейтинга в зависимости от производителя авто (СНГ - не СНГ)
                             обработчик pkage2
        16/05/2005 madiyar - исправил логическую ошибку в pkautoage
        19/05/2005 madiyar - период, в течение которого нельзя подавать повторную анкету - 1 месяц (только для Алматы)
        20/05/2005 madiyar - текст для "akires" t-anket.value2 передается через шаренную переменную v-cisres
        29/05/2005 marinav - pkdohcard добавлять баллы в соц рейтинг в зависимости отразмеров дохода
        10/06/2005 madiyar - выводится корректное сообщение о дате, когда клиент вновь может подать заявку
        05/07/2005 madiyar - поиск тек.счета в банке (pkacc1) выдавал сообщение об ошибке, исправил
        19/08/2005 madiyar - изменения в связи с повторными кредитами
        22/08/2005 madiyar - проверка просрочки удостоверения - некорректно обрабатывались клиенты с датой рождения 29/02/----
        24/08/2005 madiyar - повторные кредиты: при просрочке больше 15 дней не выкидывает, а спрашивает менеджера
        27/08/2005 madiyar - повторные кредиты: филиалы
        12/10/2005 madiyar - проверка на наличие непогашенного кредита - смотрим также уровни процентов и штрафов
        03/11/2005 madiyar - небольшие изменения в pkcomment
        10/11/2005 madiyar - pksik - не находилась соотв. запись pkkrit
        10/11/2005 madiyar - pksik - не находилась соотв. запись pkkrit
        19/04/2006 NatalyaD. - добавила процедуры (pkacccsh,pkdeps,pkwcptl,pkcred) для подарочной карты (credtype=9)
        26/04/2006 NatalyaD. - внесла изменения: если счета компании нету в Texakabank, то среднемесячные обороты можно
                               не рассчитывать, а вносить от руки.
        03/05/2006 madiyar - в связи с изменением pkdiscount.p внес изменения в вызов программы
        12/05/2006 madiyar - рефинансирование
        17/05/2006 madiyar - пропускаем пустые строки в ответе из гцвп
        19/05/2006 madiyar - в pkstage используем не общий стаж, а стаж на последнем месте работы
        26/05/2006 madiyar - проверка телефонов по базе "аист"
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        23/02/2007 madiyar - убрал лишние процедуры
        24/04/2007 madiyar - новые параметры в вызове проги pkaistrep.p; незначительные исправления
        14/05/2007 marinav - отключен запрос в ГЦВП (mailgcvp)
        17/03/08   marinav - в телефонах добавлен txb16
        22/04/2008 madiyar - примечания менеджера пишутся в t-anket.value1
        21/05/2008 madiyar - выключил рефинансирование
        19.09.2008 galina - проверка на наличие РНН в справочнике организаций, с которыми есть договоренности
        25/05/2009 madiyar - рефинансирование просрочников
        29/07/2009 galina - рефинансирование просрочников без списания процентов и шрафов
        24/08/2009 galina - изменения для полного погашения рефинансируемого кредита
        27/08/2009 galina - безналичный курс берем из sysc
        30/09/2009 galina - добаваила процедуру pkmainln для проверки наличия родительской анкеты для анкеты созаемщика
        21/10/2009 galina - не проверяем РНН созаемщика на наличие непогашенных кредитов
        04/12/2009 madiyar - при вводе номера документа созаемщика не проверяем на наличие непогашенных кредитов
        23.12.2010 madiyar - отправить данные ИИН, номер удост личн, дату выдачи УЛ в ГЦВП
        05/05/2011 madiyar - закомментировал поиск по черному списку - новых выдач нет, мешает отправлять повторные запросы в ГЦВП
		21.02.2013 id00477 ТЗ-1645 замена СИК на ИИН
*/


{global.i}
{pk.i}
{pkanket.f}
{pk-sysc.i}
{sysc.i}

def shared var v-sta as integer.
def shared var v-repeat as integer.
def shared var v-chtrans as integer.
def shared var v-refresh as logi.

def stream out1.

def new shared temp-table t-badank like pkbadlst.
def new shared var v-cisres as char init ''.

def var v-kazdigit as char extent 2 init ["123456789","?В???????"].
def var i as integer.
def var v-bank as character.

def buffer bt-anket for t-anket.

/*galina*/
def var v-comm as deci.
def var balpen as deci.
function defdata returns char (p-spr as char, p-value as char).
  def var vp-param as char.
  if p-spr = "" then vp-param = trim(caps(p-value)).
  else do:
    find bookcod where bookcod.bookcod = p-spr and bookcod.code = p-value no-lock no-error.
    if avail bookcod then vp-param = trim(caps(bookcod.name)).
    else do:
      find codfr where codfr.codfr = p-spr and codfr.code = p-value no-lock no-error.
      if avail codfr then vp-param = trim(caps(codfr.name[1])).
      else vp-param = trim(caps(p-value)).
    end.
  end.
  return vp-param.
end.

function get_ceiling returns deci (input parm1 as deci).
    def var res as deci.
    if parm1 - trunc(parm1,0) > 0 then res = trunc(parm1,0) + 1.
    else res = parm1.
    return res.
end function.

procedure pkrnn.
   def input parameter v-cod as char no-undo.
   def var balance as decimal no-undo.
   def var aaabal as decimal no-undo.
   def var v-chkrnn as integer no-undo.
   def var rnn-use as logical no-undo init false.

   def var v-res as integer no-undo.
   def var v-lon as char no-undo.
   def var v-dbt as deci no-undo.
   def var v-respr as integer no-undo.
   def var v-sum as deci no-undo.
   def var v-numpr as integer no-undo.
   def var v-maxpr as integer no-undo.
   def var choice as logi.

   find first t-anket where t-anket.kritcod = v-cod.
   find first rnn where rnn.trn = t-anket.value1 no-lock no-error.
   find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
   if avail rnn and rnn.rwho = "" then do:
        t-anket.value2 = rnn.trn.
        t-anket.value3 = "1".
        t-anket.value4 = "1".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
   end.
   else do:
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.

   v-res = 0.
   find first bt-anket where bt-anket.kritcod = "mainln" no-lock no-error.
   if (not avail bt-anket) or (bt-anket.value1 = '') then do:
       /* ищем настройку проверять/не проверять поданные ранее анкеты */
       find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "chkrnn" no-lock no-error.
       /* если настройка не найдена - считаем, что проверять надо */
       if not avail pksysc or pksysc.loval then do:
         /* по умолчанию проверяем на 3 месяца назад */
         if avail pksysc then v-chkrnn = pksysc.inval.
                         else v-chkrnn = 90.
         find last pkanketa where pkanketa.credtype = s-credtype and pkanketa.rnn = t-anket.value1 and
                                  pkanketa.rdt <= today and pkanketa.rdt > today - v-chkrnn use-index rdt no-lock no-error.
         if avail pkanketa and pkanketa.lon = "" then do:
                  message skip " Человек с указанным РНН подавал анкету " pkanketa.rdt " !~n В следующий раз он может обратиться к нам не ранее " pkanketa.rdt + v-chkrnn " ! " skip(1)
                       view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
                  v-sta = 1.
                  return.
         end.
       end.

       v-lon = ''. v-res = 0.
       for each cif where cif.jss = t-anket.value1 no-lock:
           for each lon where lon.cif = cif.cif no-lock:
               run lonbal("lon", lon.lon, g-today, "1,7,2,9,16,13,14", yes, output balance).
               if balance > 0 then do:
                    v-res = 1. v-lon = lon.lon.
                    if lon.grp <> 90 and lon.grp <> 92 then do:
                        v-res = 2. leave.
                    end.
               end.
           end.
       end.

       /*
       if v-res > 0 then do:
           message skip " У человека с указанным РНН есть непогашенный кредит! ~n Решение о выдаче кредита может быть принято только Кредитным Комитетом! " skip(1)
           view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
           v-sta = 1.
       end.
       */

       if v-res > 0 then do:
           if string(s-credtype) = "6" then do:

               if v-res = 1 then do:
                   /* проверим, подходит ли под рефинансирование */
                   /*run pkrefin(t-anket.value1, v-lon, -1, output v-respr, output v-sum, output v-numpr, output v-maxpr).*/
                   find first lon where lon.lon = v-lon no-lock no-error.
                   balance = 0.
                   /*
                   if avail lon then run lonbal("lon", lon.lon, g-today, "2,4,5,9,16,13,14,30", yes, output balance).
                   if balance > 0 then do:
                       message skip " Рефинансирование: Не списаны %% или штрафы, рефинансирование невозможно " skip(1) view-as alert-box title " Рефинансирование ".
                       v-res = 2.
                   end.
                   else do:
                   */
                       message skip " Клиент претендует на рефинансирование ~n Продолжить? " skip(1) view-as alert-box buttons yes-no title " Рефинансирование " update choice.
                       if choice then do:
                           t-anket.rescha[1] = v-lon + ",1".
                           balance = 0.
                           if avail lon then do:
                               /*galina добавила 4,5,16 и комиссионый долг*/
                               run lonbalcrc("lon", lon.lon, g-today, "1,7,2,9,4", yes, lon.crc, output balance). /* остаток ОД и процентов */

                               run lonbalcrc("lon", lon.lon, g-today, "5,16", yes, '1', output balpen). /*штрафы */

                               if lon.crc = 1 then balance = balance +  balpen.
                               else do:
                                 find first crc where crc.crc = lon.crc no-lock no-error.
                                 /*find sysc where sysc.sysc = 'erc' + crc.code no-lock.*/
                                 find sysc where sysc.sysc = 'ec' + crc.code no-lock.
                                 balance = balance +  balpen / sysc.deval. /*пересчитываем по курсу продажи безналич. валюты*/
                               end.
                               v-comm = 0.
                               for each bxcif where bxcif.cif = lon.cif and bxcif.aaa = lon.aaa and bxcif.type = '195' and bxcif.crc = lon.crc no-lock:
                                  v-comm = v-comm + bxcif.amount.
                               end.
                               balance = balance + v-comm.
                               /*********/
                               run lonbalcrc("cif", lon.aaa, g-today, "1", yes, lon.crc, output aaabal). /* остаток на счете */
                               aaabal = - aaabal.
                               /* убрала округление balance = get_ceiling(balance - aaabal).*/
                               balance = balance - aaabal.
                           end.
                           if balance > 0 then t-anket.resdec[1] = balance.
                           else do:
                               message skip " Рефинансирование: Ошибка определения суммы ОД старого кредита " skip(1) view-as alert-box error.
                               v-res = 2.
                           end.
                       end.
                       else v-res = 2.
                   /*end.*/
               end.

               if v-res = 2 then do:
                   message skip " У человека с указанным РНН есть непогашенный кредит! ~n Решение о выдаче кредита может быть принято только Кредитным Комитетом! " skip(1)
                   view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
                   v-sta = 1.
               end.

           end.
           else do: /* не БД */
               message skip " У человека с указанным РНН есть непогашенный кредит! ~n Решение о выдаче кредита может быть принято только Кредитным Комитетом ! " skip(1)
               view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
               v-sta = 1.
           end.
       end.
   end.
end.


procedure pkjobrnn.
   def input parameter v-cod as char.
   def var v-codrel as char.
   find first t-anket where  t-anket.kritcod = v-cod.
   find first rnnu where trim(rnnu.trn) = trim(t-anket.value1) no-lock no-error.
   find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
   if avail rnnu and rnnu.rwho = "" then do:
        t-anket.value2 = rnnu.trn.
        t-anket.value3 = "1".
        t-anket.value4 = "1".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
   end.
   else do:
     v-codrel = "".
     if length(v-cod) > length("jobrnn") then v-codrel = substr (v-cod, 7).
     find first t-anket where t-anket.kritcod = "joborg" + v-codrel no-error.
     if avail t-anket and t-anket.value1 begins "в/ч" then do:
       /* у воинских частей не проверяем РНН, название и адрес организации */
       find first t-anket where t-anket.kritcod = v-cod.
       t-anket.value2 = " Воинская часть".
       t-anket.value3 = "1".
       t-anket.value4 = "1".
       t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])). /* 24.11.2003 nadejda */
       t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
     end.
     else do:
        find first t-anket where  t-anket.kritcod = v-cod.
        t-anket.value2 = " РНН не найден !!!".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   /*02.09.2008 galina проверка на наличие РНН в справочнке организаций, с которыми есть договоренности*/
   find first t-anket where  t-anket.kritcod = v-cod.
   find last lnpriv where lnpriv.credtype = s-credtype and lnpriv.bank = s-ourbank and (g-today >= lnpriv.dtb and lnpriv.dte > g-today) and lnpriv.rnn = trim(t-anket.value1) no-lock no-error.
   if avail lnpriv then
    message "РНН организации найден в справочнике по спец.условиям кредитования.~n"
            "При выдаче кредита будут использованы следующие условия кредитования:~n"
            "Процентная ставка " string(lnpriv.rateq,'>>9.99') "~nКомиссия за выдачу кредита" string(lnpriv.compay,'>>9.99')
            "~nКомиссия за ведение счета" string(lnpriv.comacc,'>>9.99') view-as alert-box title "СПЕЦУСЛОВИЯ КРЕДИТОВАНИЯ".

end.

procedure pknamjob.
   def input parameter v-cod as char.
   def var v-codrel as char.

   v-codrel = "".
   if length(v-cod) > length("joborg") then v-codrel = substr (v-cod, 7).

   find first t-anket where t-anket.kritcod = "jobrnn" + v-codrel no-lock no-error.
   if avail t-anket then do:
     find first rnnu where rnnu.trn = trim(t-anket.value1) no-lock no-error.
     find first t-anket where t-anket.kritcod = v-cod no-error.
     find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
     if avail rnnu and rnnu.rwho = "" then do:
          t-anket.value2 = substr(rnnu.busname,1,50).
          if caps(t-anket.value1) = caps(rnnu.busname) then do:
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
          end.
          else do:
             t-anket.value3 = "0".
             t-anket.value4 = "0".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
          end.
     end.
     else do:
       if t-anket.value1 begins "в/ч" then do:
          /* у воинских частей не проверяем РНН, название и адрес организации */
          t-anket.value2 = " Воинская часть".
          t-anket.value3 = "1".
          t-anket.value4 = "1".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])). /* 24.11.2003 nadejda */
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).

          find first t-anket where  t-anket.kritcod = "jobrnn" + v-codrel no-error.
          find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
          if avail t-anket then do:
            t-anket.value2 = " Воинская часть".
            t-anket.value3 = "1".
            t-anket.value4 = "1".
            t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])). /* 24.11.2003 nadejda */
            t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
          end.

          find first t-anket where t-anket.kritcod = "jobadd" + v-codrel no-error.
          find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
          if avail t-anket then do:
            t-anket.value2 = " Воинская часть".
            t-anket.value3 = "1".
            t-anket.value4 = "1".
            t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])). /* 24.11.2003 nadejda */
            t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
          end.
       end.
       else do:
          t-anket.value2 = " РНН не найден !!!".
          t-anket.value3 = "0".
          t-anket.value4 = "0".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
       end.
     end.
   end.
   else do:
      find first t-anket where t-anket.kritcod = v-cod no-error.
      find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
      t-anket.value2 = " РНН не найден !!!".
      t-anket.value3 = "0".
      t-anket.value4 = "0".
      t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
      t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.
end.

procedure pkadrjob.
   def input parameter v-cod as char.
   def var v-codrel as char.

   v-codrel = "".
   if length(v-cod) > length("jobadd") then v-codrel = substr (v-cod, 7).

   find first t-anket where t-anket.kritcod = "jobrnn" + v-codrel no-lock no-error.
   if avail t-anket then do:
     find first rnnu where rnnu.trn = t-anket.value1 no-lock no-error.
     find first t-anket where t-anket.kritcod = v-cod no-error.
     find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
     if avail rnnu and rnnu.rwho = "" then do:
          t-anket.value2 = substr(rnnu.street1,1,17) + " " + substr(rnnu.housen1,1,3) + " " +
                           substr(rnnu.apartn1,1,3).
          if caps(t-anket.value1) = caps(t-anket.value2) then do:
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
          end.
          else do:
             t-anket.value3 = "0".
             t-anket.value4 = "0".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
          end.
     end.
     else do:
       find first t-anket where t-anket.kritcod = "joborg" + v-codrel no-error.
       if t-anket.value1 begins "в/ч" then do:
         /* у воинских частей не проверяем РНН, название и адрес организации */
         find first t-anket where t-anket.kritcod = v-cod.
         t-anket.value2 = " Воинская часть".
         t-anket.value3 = "1".
         t-anket.value4 = "1".
         t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])). /* 24.11.2003 nadejda */
         t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
       end.
       else do:
          find first t-anket where t-anket.kritcod = v-cod.
          t-anket.value2 = " РНН не найден !!!".
          t-anket.value3 = "0".
          t-anket.value4 = "0".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
       end.
     end.
   end.
   else do:
      find first t-anket where t-anket.kritcod = v-cod.
      find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
      t-anket.value2 = " РНН не найден !!!".
      t-anket.value3 = "0".
      t-anket.value4 = "0".
      t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
      t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.
end.

procedure pkdtrnn.
   def input parameter v-cod as char.
   def var v-codrel as char.

   v-codrel = "".
   if length(v-cod) > length("dtrnn") then v-codrel = substr (v-cod, 6).

   find first t-anket where t-anket.kritcod = "rnn" + v-codrel no-lock no-error.
   if avail t-anket then do:
     find first rnn where rnn.trn = t-anket.value1 no-lock no-error.
     find first t-anket where t-anket.kritcod = v-cod no-error.
     find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
     if avail rnn and rnn.rwho = "" then do:
          t-anket.value2 = string(rnn.datdok).
          if date(t-anket.value1) = rnn.datdok then do:
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
          end.
          else do:
             t-anket.value3 = "0".
             t-anket.value4 = "0".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
          end.
     end.
     else do:
          t-anket.value2 = "".
          t-anket.value3 = "0".
          t-anket.value4 = "0".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   else do:
        find first t-anket where t-anket.kritcod = v-cod no-error.
        find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.
end.



procedure pklname.
   def input parameter v-cod as char.
   def var v-val as char.
   def var v-codrel as char.

   v-codrel = "".
   if length(v-cod) > length("lname") then v-codrel = substr (v-cod, 6).

   find first t-anket where t-anket.kritcod = "rnn" + v-codrel no-lock no-error.
   if avail t-anket then do:
     find first rnn where rnn.trn = t-anket.value1 no-lock no-error.
     find first t-anket where  t-anket.kritcod = v-cod no-error.
     find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
     if avail rnn and rnn.rwho = "" then do:
          t-anket.value2 = rnn.lname.

          v-val = caps(t-anket.value1).
          do i = 1 to length(v-kazdigit[1]):
            v-val = replace(v-val, substr(v-kazdigit[1], i, 1), substr(v-kazdigit[2], i, 1)).
          end.

          if v-val = caps(rnn.lname) then do:
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
          end.
          else do:
             t-anket.value3 = "0".
             t-anket.value4 = "0".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
          end.
     end.
     else do:
          t-anket.value2 = "".
          t-anket.value3 = "0".
          t-anket.value4 = "0".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   else do:
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.
end.

procedure pkfname.
   def input parameter v-cod as char.
   def var v-val as char.
   def var v-codrel as char.

   v-codrel = "".
   if length(v-cod) > length("fname") then v-codrel = substr (v-cod, 6).

   find first t-anket where t-anket.kritcod = "rnn" + v-codrel no-lock no-error.
   if avail t-anket then do:
     find first rnn where rnn.trn = t-anket.value1 no-lock no-error.
     find first t-anket where  t-anket.kritcod = v-cod no-error.
     find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
     if avail rnn and rnn.rwho = "" then do:
          t-anket.value2 = rnn.fname.

          v-val = caps(t-anket.value1).
          do i = 1 to length(v-kazdigit[1]):
            v-val = replace(v-val, substr(v-kazdigit[1], i, 1), substr(v-kazdigit[2], i, 1)).
          end.

          if v-val = caps(rnn.fname) then do:
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
          end.
          else do:
             t-anket.value3 = "0".
             t-anket.value4 = "0".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
          end.
     end.
     else do:
          t-anket.value2 = "".
          t-anket.value3 = "0".
          t-anket.value4 = "0".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   else do:
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.

end.


procedure pkmname.
   def input parameter v-cod as char.
   def var v-val as char.
   def var v-codrel as char.

   v-codrel = "".
   if length(v-cod) > length("mname") then v-codrel = substr (v-cod, 6).

   find first t-anket where t-anket.kritcod = "rnn" + v-codrel no-lock no-error.
   if avail t-anket then do:
     find first rnn where rnn.trn = t-anket.value1 no-lock no-error.
     find first t-anket where t-anket.kritcod = v-cod no-error.
     find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
     if avail rnn and rnn.rwho = "" then do:
          t-anket.value2 = rnn.mname.

          v-val = caps(t-anket.value1).
          do i = 1 to length(v-kazdigit[1]):
            v-val = replace(v-val, substr(v-kazdigit[1], i, 1), substr(v-kazdigit[2], i, 1)).
          end.

          if v-val = caps(rnn.mname) then do:
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
          end.
          else do:
             t-anket.value3 = "0".
             t-anket.value4 = "0".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
          end.
     end.
     else do:
          t-anket.value2 = "".
          t-anket.value3 = "0".
          t-anket.value4 = "0".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   else do:
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.

end.


procedure pkbdt.
   def input parameter v-cod as char.
   def var v-codrel as char.

   v-codrel = "".
   if length(v-cod) > length("bdt") then v-codrel = substr (v-cod, 4).

   find first t-anket where t-anket.kritcod = "rnn" + v-codrel no-lock no-error.
   if avail t-anket then do:
     find first rnn where rnn.trn = t-anket.value1 no-lock no-error.
     find first t-anket where  t-anket.kritcod = v-cod no-error.
     find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
     if avail rnn and rnn.rwho = "" then do:
          t-anket.value2 = string(rnn.byear).
          if date(t-anket.value1) = rnn.byear then do:
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
          end.
          else do:
             t-anket.value3 = "0".
             t-anket.value4 = "0".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
          end.
     end.
     else do:
          t-anket.value2 = "".
          t-anket.value3 = "0".
          t-anket.value4 = "0".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   else do:
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.

end.


procedure pkpas.
   def input parameter v-cod as char.
   def var v-doc as char.
   def var v-codrel as char.
   def var v-refin as logi init no.
   def var v-reflon as char init ''.
   def var v-credtype as char.
   v-codrel = "".
   if length(v-cod) > length("numpas") then v-codrel = substr (v-cod, 7).

   find first t-anket where t-anket.kritcod = "rnn" + v-codrel no-lock no-error.
   if avail t-anket then do:

     if t-anket.rescha[1] <> '' and t-anket.resdec[1] > 0 then do:
       v-refin = yes.
       v-reflon = entry(1,t-anket.rescha[1]).
     end.

     find first rnn where rnn.trn = t-anket.value1 no-lock no-error.
     find first t-anket where  t-anket.kritcod = v-cod no-error.
     find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
     if avail rnn and rnn.rwho = "" and rnn.serpas begins "УД" then do:
          t-anket.value2 = string(rnn.nompas).
          if t-anket.value1 = rnn.nompas then do:
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
          end.
          else do:
             t-anket.value3 = "0".
             t-anket.value4 = "0".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
          end.
     end.
     else do:
          t-anket.value2 = "".
          t-anket.value3 = "0".
          t-anket.value4 = "0".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   else do:
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.

   if v-codrel = "" and lookup(string(s-credtype),"5,6,7") > 0 then do:
     def var vp-find as logical.
     def var vp-rowid as char.
     def var vp-name as char.
     def var vp-bdt as char.

     for each t-badank. delete t-badank. end.
     create t-badank.

     find first t-anket where t-anket.kritcod = "rnn" no-error.
     if avail t-anket then t-badank.rnn = caps(trim(t-anket.value1)).

     find first t-anket where t-anket.kritcod = "numpas" no-error.
     if avail t-anket then t-badank.docnum = caps(trim(t-anket.value1)).

     find first t-anket where t-anket.kritcod = "lname" no-error.
     if avail t-anket then t-badank.lname = caps(trim(t-anket.value1)).

     find first t-anket where t-anket.kritcod = "fname" no-error.
     if avail t-anket then t-badank.fname = caps(trim(t-anket.value1)).

     find first t-anket where t-anket.kritcod = "mname" no-error.
     if avail t-anket then t-badank.mname = caps(trim(t-anket.value1)).

     /* на всякий случай пока заменяем казахские буквы на русские */
     run pkdeffio (input-output t-badank.lname).
     run pkdeffio (input-output t-badank.fname).
     run pkdeffio (input-output t-badank.mname).

     find first t-anket where t-anket.kritcod = "bdt" no-error.
     if avail t-anket then t-badank.bdt = date(t-anket.value1).

     release t-badank.
     /*
     run pkblackch0 (output vp-find, output vp-rowid).

     if vp-find and vp-rowid <> "" then do:
       find pkbadlst where rowid(pkbadlst) = to-rowid(vp-rowid) no-lock no-error.
       vp-name = pkbadlst.lname + " " + pkbadlst.fname + " " + pkbadlst.mname.
       if pkbadlst.bdt = ? then vp-bdt = "".
                           else vp-bdt = string(pkbadlst.bdt).
       message skip
              " Обнаружено совпадение данных с ЧЕРНЫМ СПИСКОМ !" skip(1)
              " РНН       : " pkbadlst.rnn fill(" ", length(vp-name) - length(pkbadlst.rnn)) skip
              " Удост-ние : " pkbadlst.docnum fill(" ", length(vp-name) - length(pkbadlst.docnum)) skip
              " Имя       : " vp-name skip
              " Дата рожд.: " vp-bdt fill(" ", length(vp-name) - length(string(vp-bdt))) skip
              " Год рожд. : " string(pkbadlst.ybdt, "9999") fill(" ", length(vp-name) - 4)
              skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
       v-sta = 2.
       return.
     end.
     */
   end.

   find first bt-anket where bt-anket.kritcod = "mainln" no-lock no-error.
   if (not avail bt-anket) or (bt-anket.value1 = '') then do:
       if v-codrel = "" and lookup(string(s-credtype),"5,6,7") > 0 then do:
         def var v-respr as integer.
         def var v-numpr as integer.
         def var v-maxpr as integer.
         def var v-lnlast as integer.
         def var v-msgcp as char.
         def var choice as logi.
         find first t-anket where t-anket.kritcod = "rnn" no-lock no-error.
         if not avail t-anket then do:
           message " Не найден РНН клиента! " view-as alert-box buttons ok.
           return.
         end.

         v-repeat = 0.
         if not v-refin then do:
              run pkdiscount(t-anket.value1, -1, yes, output v-respr, output v-numpr, output v-maxpr, output v-lnlast).
              /*   message ' v-respr=' v-respr ' v-numpr=' v-numpr ' v-maxpr=' v-maxpr ' v-lnlast' v-lnlast. */
              if v-respr > 0 then do:
                 case v-respr:
                   when 1 then do:
                     if v-maxpr < 5 then do: v-repeat = 1. v-chtrans = 1. end.
                     if v-maxpr >= 5 then do:
                       message skip " Клиент обращается повторно ~n Допущено просрочек - " v-numpr ", макс. просрочка - " v-maxpr " дней ~n Кредит будет вынесен на Кредитный Комитет " skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
                       v-repeat = 2. v-chtrans = 1.
                     end.
                   end.
                   when 2 then do:
                     message skip " У человека с указанным РНН есть непогашенный кредит! " skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
                     v-sta = 1. return.
                   end.
                   when 3 then do:
                     choice = no.
                     message skip " Клиент обращается повторно ~n Допущено просрочек - " v-numpr ", макс. просрочка - " v-maxpr " дней ~n Продолжить? (кредит будет вынесен на Кредитный Комитет) " skip(1) view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update choice.
                     if choice then do: v-repeat = 2. v-chtrans = 1. end. /* на КК с льготными условиями */
                     else do: v-sta = 3. return. end.
                   end.
                 end case.
              end.
         end.
         else do:
           v-repeat = 1. v-chtrans = 1.
           find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = v-reflon no-lock no-error.
           if not avail pkanketa then do:
               v-lnlast = 0.
               message skip " Рефинансирование: исходная анкета не найдена ~n Копирование данных невозможно " + v-reflon skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
           end.
           else do:
             v-lnlast = pkanketa.ln.
             v-credtype = pkanketa.credtype.
           end.
           /* при рефинансировании заходим в копирование анкеты, но проводка комиссии запрашивается, и признак повторности не проставляется */
         end.

           if v-repeat = 1 or v-repeat = 2 then do:
             find first t-anket where t-anket.kritcod = v-cod no-error.

             if v-refin then do:
                 /* если рефинансирование - льготы по повторным не нужны! */
                 v-msgcp = " Анкета на рефинансирование ~n Копировать информацию? ".
             end.
             else do:
                 t-anket.rescha[3] = string(v-repeat). /* признак для установки льгот по повторным */
                 v-msgcp = " Клиент обращается повторно ~n Копировать информацию? ".
             end.

             choice = yes.
             message skip v-msgcp skip(1) view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update choice.
             if choice then do:
               for each pkkrit where pkkrit.priz = "1" and lookup (s-credtype, pkkrit.credtype) > 0 use-index kritcod no-lock:
                 if lookup(pkkrit.kritcod,"rnn,lname,fname,mname,pname,siktwo,numpas") > 0 then next.
                 /*find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = v-lnlast and pkanketh.kritcod = pkkrit.kritcod no-lock no-error.*/
                 find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = v-credtype and pkanketh.ln = v-lnlast and pkanketh.kritcod = pkkrit.kritcod no-lock no-error.
                 if avail pkanketh then do:
                   find first t-anket where t-anket.kritcod = pkkrit.kritcod no-error.
                   if avail t-anket then t-anket.value1 = pkanketh.value1.
                 end. /* if avail pkanketh */
               end. /* for each pkkrit */
               v-refresh = yes.
             end. /* if choice */
           end. /* if v-repeat = 1 or v-repeat = 2 */

       end.
    end. /* if (not avail bt-anket) or (bt-anket.value1 = '') */
end.

procedure pkdtpas.
   def input parameter v-cod as char.
   def var v-dt1 as date.
   def var v-dt2 as date.
   def var v-dt3 as date.
   def var v-codrel as char.

   v-codrel = "".
   if length(v-cod) > length("dtpas") then v-codrel = substr (v-cod, 6).

   find first t-anket where t-anket.kritcod = "bdt" + v-codrel no-lock no-error.
   if avail t-anket then do:
     v-dt1 = date(t-anket.value1).
     find first t-anket where t-anket.kritcod = v-cod no-error.
     v-dt2 = date(t-anket.value1).
     if day(v-dt1) = 29 and month(v-dt1) = 2 then v-dt3 = date("28/02/" + string(year(v-dt1) + 25)).
     else v-dt3 = date(string(day(v-dt1)) + "/" + string(month(v-dt1)) + "/" + string(year(v-dt1) + 25)).
     if v-dt3 < today and v-dt3 > v-dt2 then do:
              message skip " Обратите внимание на дату удостоверения !~n Оно может быть просрочено !" skip(1)
                   view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
     end.

     if day(v-dt1) = 29 and month(v-dt1) = 2 then v-dt3 = date("28/02/" + string(year(v-dt1) + 45)).
     else v-dt3 = date(string(day(v-dt1)) + "/" + string(month(v-dt1)) + "/" + string(year(v-dt1) + 45)).
     if v-dt3 < today and v-dt3 > v-dt2 then do:
              message skip " Обратите внимание на дату удостоверения !~n Оно может быть просрочено !" skip(1)
                   view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
     end.

     find first t-anket where t-anket.kritcod = "rnn" + v-codrel no-lock no-error.
     if avail t-anket then do:
       find first rnn where rnn.trn = t-anket.value1 no-lock no-error.
       find first t-anket where  t-anket.kritcod = v-cod no-error.
       find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
       if avail rnn and rnn.rwho = "" and rnn.serpas = "УДОСТОВ" then do:
            t-anket.value2 = string(rnn.datepas).
            if date(t-anket.value1) = rnn.datepas then do:
               t-anket.value3 = "1".
               t-anket.value4 = "1".
               t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
               t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
            end.
            else do:
               t-anket.value3 = "0".
               t-anket.value4 = "0".
               t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
               t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
            end.
       end.
       else do:
            t-anket.value2 = "".
            t-anket.value3 = "0".
            t-anket.value4 = "0".
            t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
            t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
       end.
     end.
     else do:
          find first t-anket where  t-anket.kritcod = v-cod no-error.
          find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
          t-anket.value2 = "".
          t-anket.value3 = "0".
          t-anket.value4 = "0".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   else do:
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.
end.

procedure pkcity1.
   def input parameter v-cod as char.
   def var v-param as char.

   find first t-anket where t-anket.kritcod = "rnn"  no-lock no-error.
   if avail t-anket then do:
     find first rnn where rnn.trn = t-anket.value1 no-lock no-error.
     find first t-anket where  t-anket.kritcod = v-cod no-error.
     find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
     if avail rnn and rnn.rwho = "" then do:
          t-anket.value2 = rnn.city1.

          if num-entries(pkkrit.kritspr) = 1 then v-param = defdata (pkkrit.kritspr, t-anket.value1).
          else v-param = defdata (entry(integer(s-credtype),pkkrit.kritspr), t-anket.value1).

          if v-param = trim(caps(rnn.city1)) then do:
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
          end.
          else do:
             t-anket.value3 = "0".
             t-anket.value4 = "0".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
          end.
     end.
     else do:
          t-anket.value2 = "".
          t-anket.value3 = "0".
          t-anket.value4 = "0".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   else do:
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.
end.

procedure pkstr1.
   def input parameter v-cod as char.
   def var v-param as char.
   find first t-anket where  t-anket.kritcod = "rnn"  no-lock no-error.
   if avail t-anket then do:
     find first rnn where rnn.trn = t-anket.value1 no-lock no-error.
     find first t-anket where  t-anket.kritcod = v-cod no-error.
     find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
     if avail rnn and rnn.rwho = "" then do:
          t-anket.value2 = rnn.street1.

          if num-entries(pkkrit.kritspr) = 1 then v-param = defdata (pkkrit.kritspr, t-anket.value1).
          else v-param = defdata (entry(integer(s-credtype),pkkrit.kritspr), t-anket.value1).

          if v-param = trim(caps(rnn.street1)) then do:
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
          end.
          else do:
             t-anket.value3 = "0".
             t-anket.value4 = "0".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
          end.
     end.
     else do:
          t-anket.value2 = "".
          t-anket.value3 = "0".
          t-anket.value4 = "0".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   else do:
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.
end.

procedure pkhou1.
   def input parameter v-cod as char.
   find first t-anket where  t-anket.kritcod = "rnn"  no-lock no-error.
   if avail t-anket then do:
     find first rnn where rnn.trn = t-anket.value1 no-lock no-error.
     find first t-anket where  t-anket.kritcod = v-cod no-error.
     find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
     if avail rnn and rnn.rwho = "" then do:
          t-anket.value2 = rnn.housen1.
          if trim(t-anket.value1) = trim(rnn.housen1) then do:
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
          end.
          else do:
             t-anket.value3 = "0".
             t-anket.value4 = "0".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
          end.
     end.
     else do:
          t-anket.value2 = "".
          t-anket.value3 = "0".
          t-anket.value4 = "0".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   else do:
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.
end.

procedure pkauto.
   def input parameter v-cod as char.
   def var v-num as char.
   def var v-rnn as char.
   find first t-anket where  t-anket.kritcod = v-cod no-error.
   v-num = trim(caps(t-anket.value1)).
   find last taxauto where taxauto.number = v-num use-index number no-lock no-error.
   find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
   if avail taxauto then do:
      find first rnn where rnn.trn = taxauto.rnn no-lock no-error.
      if avail rnn and rnn.rwho = "" then do:
         t-anket.value2 = rnn.lname + " " + rnn.fname + " " + rnn.mname.
      end.
      find first t-anket where  t-anket.kritcod = "rnn"  no-lock no-error.
      if avail t-anket then do:
        v-rnn = t-anket.value1.
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        if v-rnn = taxauto.rnn then do:
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
        end.
        else do:
             t-anket.value3 = "0".
             t-anket.value4 = "0".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
        end.
      end.
      else do:
           find first t-anket where  t-anket.kritcod = v-cod no-error.
           t-anket.value3 = "0".
           t-anket.value4 = "0".
           t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
           t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
      end.
   end.
   else do:
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        t-anket.value2 = "не зарегистрирована".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.
end.

procedure pkautm.
   def input parameter v-cod as char.
   def var v-num as char.
   def var v-param as char.
   find first t-anket where  t-anket.kritcod = "auto" no-error.
   if avail t-anket then do:
     v-num = trim(caps(t-anket.value1)).
     find last taxauto where taxauto.number = v-num use-index number no-lock no-error.
     find first t-anket where  t-anket.kritcod = v-cod no-error.
     find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
     if avail taxauto then do:
        t-anket.value2 = taxauto.model.

        if num-entries(pkkrit.kritspr) = 1 then v-param = defdata (pkkrit.kritspr, t-anket.value1).
        else v-param = defdata (entry(integer(s-credtype),pkkrit.kritspr), t-anket.value1).

        if v-param = trim(caps(taxauto.model)) then do:
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
        end.
        else do:
             t-anket.value3 = "0".
             t-anket.value4 = "0".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
        end.
     end.
     else do:
          find first t-anket where  t-anket.kritcod = v-cod no-error.
          t-anket.value2 = "не загегистрирована".
          t-anket.value3 = "0".
          t-anket.value4 = "0".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   else do:
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.
end.

procedure pkauty.
   def input parameter v-cod as char.
   def var v-num as char.
   find first t-anket where  t-anket.kritcod = "auto" no-error.
   if avail t-anket then do:
     v-num = t-anket.value1.
     find last taxauto where taxauto.number = v-num use-index number no-lock no-error.
     find first t-anket where  t-anket.kritcod = v-cod no-error.
     find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
     if avail taxauto then do:
        t-anket.value2 = taxauto.year.
        if trim(caps(t-anket.value1)) = trim(caps(taxauto.year)) then do:
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
        end.
        else do:
             t-anket.value3 = "0".
             t-anket.value4 = "0".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
        end.
     end.
     else do:
          find first t-anket where  t-anket.kritcod = v-cod no-error.
          t-anket.value2 = "не загегистрирована".
          t-anket.value3 = "0".
          t-anket.value4 = "0".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   else do:
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.
end.

procedure pkapar1.
   def input parameter v-cod as char.
   find first t-anket where  t-anket.kritcod = "rnn"  no-lock no-error.
   if avail t-anket then do:
     find first rnn where rnn.trn = t-anket.value1 no-lock no-error.
     find first t-anket where  t-anket.kritcod = v-cod no-error.
     find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
     if avail rnn and rnn.rwho = "" then do:
          t-anket.value2 = rnn.apartn1.
          if trim(t-anket.value1) = trim(rnn.apartn1) then do:
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
          end.
          else do:
             t-anket.value3 = "0".
             t-anket.value4 = "0".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
          end.
     end.
     else do:
          t-anket.value2 = "".
          t-anket.value3 = "0".
          t-anket.value4 = "0".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   else do:
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.
end.

/*procedure pksik.
  def input parameter v-cod as char.
  def var p-sik as char.
  def var p-lastname as char.
  def var p-firstname as char.
  def var p-midname as char.
  def var p-plastname as char.
  def var p-birthdt as date init today.
  def var v-codrel as char.
  def var v-answer as logical.

  find first t-anket where t-anket.kritcod = v-cod no-error.
  find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
  if t-anket.value1 ne "" then do:

    p-sik = t-anket.value1.

    v-codrel = "".
    if length(v-cod) > length("sik") then v-codrel = substr (v-cod, 4).*/

    /* на всякий случай пока заменяем казахские буквы на русские, потом будет соглашение о казахских спецсимволах */
    /*find first t-anket where  t-anket.kritcod = "lname" + v-codrel no-lock no-error.
    if avail t-anket then p-lastname = t-anket.value1.
    run pkdeffio (input-output p-lastname).

    find first t-anket where  t-anket.kritcod = "fname" + v-codrel no-lock no-error.
    if avail t-anket then p-firstname = t-anket.value1.
    run pkdeffio (input-output p-firstname).

    find first t-anket where  t-anket.kritcod = "mname" + v-codrel no-lock no-error.
    if avail t-anket then p-midname = t-anket.value1.
    run pkdeffio (input-output p-midname).

    find first t-anket where  t-anket.kritcod = "pname" + v-codrel no-lock no-error.
    if avail t-anket then p-plastname = t-anket.value1.
    run pkdeffio (input-output p-plastname).

    find first t-anket where  t-anket.kritcod = "bdt" + v-codrel no-lock no-error.
    if avail t-anket then p-birthdt = date(t-anket.value1).
    run siktest(p-sik,p-lastname,p-firstname,p-midname,p-plastname,"","",p-birthdt).
    find first t-anket where  t-anket.kritcod = v-cod no-error.
    if return-value = "0" then do:
        t-anket.value2 = t-anket.value1.
        t-anket.value3 = "1".
        t-anket.value4 = "1".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
    end.
    else do:
        t-anket.value2 = "  СИК неверный !!!".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
    end.

    v-answer = yes.
    message skip " Сформировать запрос в ГЦВП ?" skip(1)
            view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-answer.
    if v-answer then run mailgcvp (v-cod).

  end.
end.*/

procedure pkalma.

  def input parameter v-cod as char.
  def var v-falm as char.
  def var v-ioalm as char.
  def var v-ialm as char.
  def var v-oalm as char.

  /* на всякий случай пока заменяем казахские буквы на русские */
  find first t-anket where t-anket.kritcod = "lname" no-error.
  if avail t-anket then v-falm = caps(trim(t-anket.value1)).
  run pkdeffio (input-output v-falm).

  find first t-anket where t-anket.kritcod = "fname" no-error.
  if avail t-anket then v-ialm = caps(trim(t-anket.value1)).
  run pkdeffio (input-output v-ialm).

  find first t-anket where t-anket.kritcod = "mname" no-error.
  if avail t-anket then v-oalm = caps(trim(t-anket.value1)).
  run pkdeffio (input-output v-oalm).

  v-ioalm = trim(v-ialm + " " + v-oalm).

  find first almatv where f = v-falm and io = v-ioalm no-lock no-error.
  find first t-anket where t-anket.kritcod = v-cod no-error.
  find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
  t-anket.value2 = "".
  if avail almatv then do:
        find first t-anket where t-anket.kritcod = v-cod no-error.
        if int(t-anket.value1) > 0 then do:
           t-anket.value3 = "1".
           t-anket.value4 = "1".
           t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
           t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
        end.
        else do:
           t-anket.value3 = "1".
           t-anket.value4 = "1".
           t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
           t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
        end.
   end.
   else do:
        t-anket.value3 = "1".
        t-anket.value4 = "1".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
  end.
end.

procedure pkaldol.

  def input parameter v-cod as char.
  def var v-falm as char.
  def var v-ioalm as char.
  def var v-ialm as char.
  def var v-oalm as char.
  def var v-maxdolg as decimal.

  v-maxdolg = get-pksysc-dec ("almdol").

  /* на всякий случай пока заменяем казахские буквы на русские */
  find first t-anket where t-anket.kritcod = "lname" no-error.
  if avail t-anket then v-falm = caps(trim(t-anket.value1)).
  run pkdeffio (input-output v-falm).

  find first t-anket where t-anket.kritcod = "fname" no-error.
  if avail t-anket then v-ialm = caps(trim(t-anket.value1)).
  run pkdeffio (input-output v-ialm).

  find first t-anket where t-anket.kritcod = "mname" no-error.
  if avail t-anket then v-oalm = caps(trim(t-anket.value1)).
  run pkdeffio (input-output v-oalm).

  v-ioalm = trim(v-ialm + " " + v-oalm).

  find first almatv where f = v-falm and io = v-ioalm no-lock no-error.
  find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
  if avail almatv then do:
        find first t-anket where t-anket.kritcod = v-cod no-error.
        t-anket.value2 = string(almatv.summ - almatv.summfk).
        if almatv.summ - almatv.summfk > v-maxdolg then do:
           t-anket.value3 = "1".
           t-anket.value4 = "1".
           t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
           t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
        end.
        else do:
           t-anket.value3 = "1".
           t-anket.value4 = "1".
           t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
           t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
        end.
  end.
  else do:
        find first t-anket where t-anket.kritcod = v-cod no-error.
        t-anket.value2 = "".
        t-anket.value3 = "1".
        t-anket.value4 = "1".
        t-anket.rating = 0.
        t-anket.resdec[5] = 0.
  end.
end.


procedure pkacc1.
   def input parameter v-cod as char.
   def var yn as logi init false.
   def var v-aaa like aaa.aaa.
   find first t-anket where  t-anket.kritcod = "rnn".
   if avail t-anket then do:
     find first cif where cif.jss = t-anket.value1 no-lock no-error.
     find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
     if avail cif then do:
          for each cif where cif.jss = t-anket.value1 no-lock:
            find first aaa where aaa.cif = cif.cif and (aaa.lgr begins "1" or aaa.lgr begins "2") and aaa.sta ne "C" no-lock no-error.
            if avail aaa then do:
              yn = true.
              v-aaa = aaa.aaa.
            end.
          end.
          if yn then do:
             find first t-anket where t-anket.kritcod = v-cod no-error.
             t-anket.value2 = v-aaa.
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
          end.
          else do:
             find first t-anket where t-anket.kritcod = v-cod no-error.
             t-anket.value2 = "".
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
          end.
     end.
     else do:
          find first t-anket where t-anket.kritcod = v-cod no-error.
          t-anket.value2 = "".
          t-anket.value3 = "1".
          t-anket.value4 = "1".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   else do:
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.
end.

procedure pkacc2.
   def input parameter v-cod as char.
   def var ss as logi.
   def var m-aaa as char.
   find first t-anket where  t-anket.kritcod = "rnn".
   if avail t-anket then do:
     find first cif where cif.jss = t-anket.value1 no-lock no-error.
     find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
     if avail cif then do:
          /*find first aaa where aaa.cif = cif.cif and (aaa.lgr begins "d" or aaa.lgr begins "3" or aaa.lgr begins "4") and aaa.sta ne "C" no-lock no-error.*/
          ss = no.
          for each aaa where aaa.cif = cif.cif and aaa.sta <> "C" and aaa.sta <> "E" no-lock:
            find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
            if lgr.led = "TDA" then do: ss = yes. m-aaa = aaa.aaa. leave. end.
          end.
          if ss then do:
             find first t-anket where t-anket.kritcod = v-cod no-error.
             t-anket.value2 = m-aaa.
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
          end.
          else do:
             find first t-anket where t-anket.kritcod = v-cod no-error.
             t-anket.value2 = "".
             t-anket.value3 = "1".
             t-anket.value4 = "1".
             t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
          end.
     end.
     else do:
          find first t-anket where t-anket.kritcod = v-cod no-error.
          t-anket.value2 = "".
          t-anket.value3 = "1".
          t-anket.value4 = "1".
          t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
          t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
   end.
   else do:
        find first t-anket where  t-anket.kritcod = v-cod no-error.
        find first pkkrit where pkkrit.kritcod = t-anket.kritcod no-lock no-error.
        t-anket.value2 = "".
        t-anket.value3 = "0".
        t-anket.value4 = "0".
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.
end.

procedure pkrat.
   def input parameter v-cod as char.
   def var v-answer as logical.

   find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
   find first t-anket where t-anket.kritcod = v-cod no-error.
   if not avail t-anket then do:
     create t-anket.
     assign t-anket.bank = s-ourbank
            t-anket.credtype = s-credtype
            t-anket.ln = int(pkkrit.ln)
            t-anket.kritcod = v-cod
            t-anket.value1 = trim(pkkrit.res[2]).
   end.
   t-anket.value2 = "".
   t-anket.value3 = "1".
   t-anket.value4 = "1".

   if t-anket.value1 <> "" then do:
       t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
       t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
   end.
   else do:
       t-anket.value2 = "".
       t-anket.value3 = "0".
       t-anket.value4 = "0".
   end.

   /* аист */
   def var v-phone as char no-undo init ''.
   def var v-tname as char no-undo init ''.
   def var v-taddress as char no-undo init ''.
   def var choice as logical init no.
   if (s-ourbank = "txb00" or s-ourbank = "txb16") and lookup(v-cod,"tel,tel2,tel4") > 0 then do:
     v-phone = trim(t-anket.value1).

     if v-phone <> '' then do:
       find first phones where phones.number = v-phone no-lock no-error.
       if avail phones then assign v-tname = trim(phones.name) v-taddress = trim(phones.adress).
       else assign v-tname = '--не найден--' v-taddress = '--не найден--'.
       message "~nНомер телефона: " + v-phone + "~nФИО/Наим.: " + v-tname + "~nАдрес: " + v-taddress + "~n~nСоответствует?"
               view-as alert-box question buttons yes-no title "Сверка по номеру" update choice.
       t-anket.value2 = v-tname.
       if choice then assign t-anket.value3 = "1" t-anket.value4 = "1".
       else do:
         update t-anket.rescha[1] format "x(1000)" view-as editor size 70 by 8
           with centered row 6 overlay no-labels title "Примечание" frame telfr.
           /*
           editing:
             readkey.
             if keyfunction(lastkey) <> "RETURN" then apply lastkey.
           end.
           */
         assign t-anket.value3 = "0" t-anket.value4 = "0".
       end.
     end.
   end.
   if v-cod = "iin" then do:
		
		v-answer = yes.
		message skip " Сформировать запрос в ГЦВП ?" skip(1)
				view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-answer.
		if v-answer then run mailgcvp (v-cod).

   end.

end.

procedure pkaist.
 def input parameter v-cod as char.
 def var pars as char no-undo extent 6.

 find first t-anket where t-anket.kritcod = "tel" no-lock no-error.
 if avail t-anket then assign pars[1] = trim(t-anket.value1) pars[2] = trim(t-anket.rescha[1]).
 find first t-anket where t-anket.kritcod = "tel2" no-lock no-error.
 if avail t-anket then assign pars[3] = trim(t-anket.value1) pars[4] = trim(t-anket.rescha[1]).
 find first t-anket where t-anket.kritcod = "tel4" no-lock no-error.
 if avail t-anket then assign pars[5] = trim(t-anket.value1) pars[6] = trim(t-anket.rescha[1]).

 run pkaistrep(pars[1],pars[2],pars[3],pars[4],pars[5],pars[6],s-credtype,s-pkankln).

end.

procedure pknedvtyp0.
   def input parameter v-cod as char.
   def var v-type as char.

   find first t-anket where t-anket.kritcod = "nedvapart" no-error.
   if not avail t-anket or t-anket.value1 = "" then v-type = "2".
                                               else v-type = "1".

   find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
   find first t-anket where t-anket.kritcod = v-cod no-error.
   if not avail t-anket then do:
     create t-anket.
     assign t-anket.bank = s-ourbank
            t-anket.credtype = s-credtype
            t-anket.ln = int(pkkrit.ln)
            t-anket.kritcod = v-cod.
   end.


   assign t-anket.value1 = v-type
          t-anket.value2 = ""
          t-anket.value3 = "1"
          t-anket.value4 = "1".

   if t-anket.value1 <> "" then assign t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1]))
                                       t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
end.

procedure pkalseco.
   def input parameter v-cod as char.
   def var v-dolg as decimal.
   def var v-maxdolg as decimal.

   v-maxdolg = get-pksysc-dec ("alseco").

   find first t-anket where t-anket.kritcod = v-cod no-error.
   t-anket.value2 = trim(string(v-maxdolg, "->>>>>>>>9.99")).

   v-dolg = decimal (t-anket.value1) no-error.
   if error-status:error then v-dolg = 0.
   find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.

   if v-dolg > v-maxdolg then do:
                 t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
                 t-anket.value3 = "1".
                 t-anket.value4 = "1".
                 t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
       end.
       else do:
                 t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
                 t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
                 t-anket.value3 = "0".
                 t-anket.value4 = "0".
        end.
end.


procedure pkblacklst.
  def input parameter v-cod as char.
  def var vp-find as logical.
  def var vp-rowid as char.
  def var vp-name as char.
  def var vp-bdt as char.

  for each t-badank. delete t-badank. end.

  create t-badank.

  find first t-anket where t-anket.kritcod = "rnn" no-error.
  if avail t-anket then t-badank.rnn = caps(trim(t-anket.value1)).

  find first t-anket where t-anket.kritcod = "numpas" no-error.
  if avail t-anket then t-badank.docnum = caps(trim(t-anket.value1)).

  find first t-anket where t-anket.kritcod = "lname" no-error.
  if avail t-anket then t-badank.lname = caps(trim(t-anket.value1)).

  find first t-anket where t-anket.kritcod = "fname" no-error.
  if avail t-anket then t-badank.fname = caps(trim(t-anket.value1)).

  find first t-anket where t-anket.kritcod = "mname" no-error.
  if avail t-anket then t-badank.mname = caps(trim(t-anket.value1)).

  /* на всякий случай пока заменяем казахские буквы на русские */
  run pkdeffio (input-output t-badank.lname).
  run pkdeffio (input-output t-badank.fname).
  run pkdeffio (input-output t-badank.mname).

  find first t-anket where t-anket.kritcod = "bdt" no-error.
  if avail t-anket then t-badank.bdt = date(t-anket.value1).

  release t-badank.

  run pkblackch0 (output vp-find, output vp-rowid).


  find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
  find first t-anket where t-anket.kritcod = v-cod no-error.
  if vp-find and vp-rowid <> "" then do:
    t-anket.value1 = "".
    t-anket.value2 = vp-rowid.
    t-anket.value4 = "0".

    find pkbadlst where rowid(pkbadlst) = to-rowid(vp-rowid) no-lock no-error.

    vp-name = pkbadlst.lname + " " + pkbadlst.fname + " " + pkbadlst.mname.
    if pkbadlst.bdt = ? then vp-bdt = "".
                        else vp-bdt = string(pkbadlst.bdt).
    vp-find = no.
    message skip
            " Обнаружено совпадение данных с ЧЕРНЫМ СПИСКОМ !" skip(1)
            " РНН       : " pkbadlst.rnn fill(" ", length(vp-name) - length(pkbadlst.rnn)) skip
            " Удост-ние : " pkbadlst.docnum fill(" ", length(vp-name) - length(pkbadlst.docnum)) skip
            " Имя       : " vp-name skip
            " Дата рожд.: " vp-bdt fill(" ", length(vp-name) - length(string(vp-bdt))) skip
            " Год рожд. : " string(pkbadlst.ybdt, "9999") fill(" ", length(vp-name) - 4)
            skip(1)
            " Разрешить выдачу кредита ?"
            skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update vp-find.
    if vp-find then do:
      t-anket.value3 = "1".
      t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
      t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
    end.
    else do:
      t-anket.value3 = "0".
      t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
      t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
    end.
  end.
  else do:
    t-anket.value1 = "".
    t-anket.value2 = "".
    t-anket.value3 = "1".
    t-anket.value4 = "1".
    t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
    t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
  end.
end procedure.

/* запрос в АКИ и прием ответа */
procedure pkakires.
  def input parameter v-cod as char.
  def var v-ans as logi.
  /*def var v-codrel as char.*/

  /*if lookup(g-ofc, "u00123,u00315") = 0 then return.*/

  v-ans = no.
  message skip " Послать запрос в АКИ по данному клиенту ?"
          skip(1) view-as alert-box button yes-no title " ПОДТВЕРДИТЕ ЗАПРОС ! " update v-ans.

  if v-ans then do:
    /*
    v-codrel = "".
    if length(v-cod) > length("akires") then v-codrel = substr (v-cod, 7).
    */

    /* послать запрос в АКИ */
    run pkcisout. /* (v-codrel). */
    /*v-res = return-value.*/

    find first t-anket where t-anket.kritcod = v-cod no-error.
    t-anket.value1 = "".
    t-anket.value2 = v-cisres.
    t-anket.value3 = "1".
    t-anket.value4 = "1".
  end.
  else do:
    find first t-anket where t-anket.kritcod = v-cod no-error.
    t-anket.value3 = "0".
    t-anket.value4 = "0".
  end.
end.


procedure mailgcvp.
  def input parameter v-cod as char.
  def var p-sik as char.
  def var p-lastname as char.
  def var p-firstname as char.
  def var p-midname as char.
  def var p-plastname as char.
  def var p-birthdt as char.
  def var p-numpas as char.
  def var p-dtpas as char.
  def var v-iin as char.
  def var v-file as char.
  def var v-date as char.
  def var v-sr as char.
  def var v-dirq as char.
  def var num as inte.
  def var v-codrel as char.
  def var p-zvklad as char.

  v-codrel = "".
  if length(v-cod) > length("iin") then v-codrel = substr (v-cod, 4).
  find first t-anket where t-anket.kritcod = v-cod + v-codrel no-error.
  if not avail t-anket or t-anket.rescha[3] ne "" then do:
      message skip " Запрос данных в ГЦВП по ИИН '" + t-anket.value1 + "' уже был отправлен !" skip
                   "Дождитесь ответа !" skip(1)
              view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
      return.
  end.


  find first sysc where sysc.sysc = "PKGCVY" no-lock no-error.
  if not avail sysc or not sysc.loval then do:
    message skip " Запрос данных в ГЦВП в данный момент не работает !" skip(1)
            view-as alert-box buttons ok title " ВНИМАНИЕ ! ".

  end.
  else do:
    num = next-value(pk-gcvp).


    v-sr = string(get-pksysc-int ("gcvpsr")).
    v-date = substr(string(g-today), 1, 6) + string(year(g-today)).
    v-dirq = get-sysc-cha ("pkgcvq").
    v-file = fill("0", 8 - length(trim(string(num)))) + trim(string(num)).
  

    v-codrel = "".
    if length(v-cod) > length("sik") then v-codrel = substr (v-cod, 4).

    /*find first t-anket where t-anket.kritcod = v-cod no-error.
    p-sik = caps(trim(t-anket.value1)).*/

    find first t-anket where  t-anket.kritcod = "pname" + v-codrel no-lock no-error.
    if avail t-anket and trim(t-anket.value1) <> "" then do:
      p-lastname = caps(trim(t-anket.value1)).

      /* выяснилось, что в документе СИКа могут быть указаны и прежние, и новые данные - тогда они через слэш
         и ГЦВП проверяет по ПЕРВОМУ значению, то есть по текущей фамилии!
         для отслеживания этого факта служит критерий ciktwo :  если = 1, то посылать текущие данные, нет - старые
      */
      find first t-anket where t-anket.kritcod = "siktwo" + v-codrel no-error.
      if avail t-anket and trim(t-anket.value1) <> "" and integer(trim(t-anket.value1)) = 1 then do:
        find first t-anket where t-anket.kritcod = "lname" + v-codrel no-error.
        p-lastname = caps(trim(t-anket.value1)).
      end.
    end.
    else do:
      find first t-anket where t-anket.kritcod = "lname" + v-codrel no-error.
      p-lastname = caps(trim(t-anket.value1)).
    end.

    find first t-anket where t-anket.kritcod = "fname" + v-codrel no-error.
    if avail t-anket then p-firstname = caps(trim(t-anket.value1)).

    find first t-anket where t-anket.kritcod = "mname" + v-codrel no-error.
    if avail t-anket then p-midname = caps(trim(t-anket.value1)).

    find first t-anket where t-anket.kritcod = "bdt" + v-codrel no-error.
    if avail t-anket then p-birthdt = string(date(t-anket.value1), "99/99/9999").

    find first t-anket where t-anket.kritcod = "numpas" no-lock no-error.
    if avail t-anket then p-numpas = caps(trim(t-anket.value1)).

    find first t-anket where t-anket.kritcod = "dtpas" no-lock no-error.
    if avail t-anket then p-dtpas = string(date(t-anket.value1), "99/99/9999").

    v-iin = ''.
    find first t-anket where t-anket.kritcod = "iin".
    if avail t-anket and t-anket.value1 <> '' then v-iin = t-anket.value1.
    else do:
        find first t-anket where t-anket.kritcod = "rnn".
        find first cif where cif.jss = t-anket.value1 no-lock no-error.
        if avail cif then v-iin = cif.bin.
    end.

	
	p-zvklad = trim(string(num)).

    output stream out1 to rpt.txt.
   
    /*put stream out1 unformatted  v-file + "|" +  v-date + "|" + p-sik + "|" + p-lastname + "|" +
                                 p-firstname + "|" + p-midname + "|" + p-birthdt + "|" + p-numpas + "|" +
                                 p-dtpas + "|" + v-iin + "|" + v-file + "|" + v-date + "|2|" skip.*/

	put stream out1 unformatted  v-file + "|" +  v-date + "|" + v-iin + "|" + p-lastname + "|" +
                             p-firstname + "|" + p-midname + "|" + p-birthdt + "|" + p-numpas + "|" +
                             p-dtpas + "|" + p-zvklad + "|" + v-date + "|2|" skip.

    output stream out1 close.
    unix silent un-win rpt.txt value(v-file).
    unix silent cp value(v-file) value(v-dirq + v-file).

    find sysc where sysc.sysc = "pkgcvm" no-lock no-error.

    run mail(trim(sysc.chval), "МЕТРОКОМБАНК <abpk@metrobank.kz>",
             "Fdjkl358Jd", "" , "1", "", v-file).

    run savelog( "gcvpout", "Отправка файла в ГЦВП : " + v-file).

    find first t-anket where t-anket.kritcod = v-cod no-error.
    t-anket.rescha[3] = "metrocombank" + v-file.

    unix silent cp value(v-file) value(v-dirq + v-file).
    unix silent rm -f value(v-file).

    create gcvp.
    assign gcvp.bank = s-ourbank
           gcvp.lname = p-lastname
           gcvp.fname = p-firstname
           gcvp.mname = p-midname
           gcvp.dtb = date(p-birthdt)
           gcvp.sik = p-sik
           gcvp.ofc = g-ofc
           gcvp.rdt = g-today
           gcvp.nfile = v-file
		   gcvp.iin = v-iin.
    release gcvp.

    message skip "Запрос ї " + v-file + " отправлен в ГЦВП " skip(1)
      view-as alert-box button Ok title "Внимание!".

  end.
end.

define temp-table t-gcvp
    field txt as char format "x(50)".

procedure pkgcvpres.
  def input parameter v-cod as char.
  def var fname as char.
  def var v-dira as char.
  def var v-diri as char.
  def var i as inte.
  def var v-suma as deci.
  def var v-codrel as char.
  def var v-gcvptxt as char.

  find first sysc where sysc.sysc = "PKGCVY" no-lock no-error.
  if not avail sysc or not sysc.loval then do:
    message skip " Запрос данных в ГЦВП в данный момент не работает !" skip(1)
            view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
  end.
  else do:
    v-codrel = "".
    if length(v-cod) > length("gcvpres") then v-codrel = substr (v-cod, 8).

    /*find first t-anket where t-anket.kritcod = "sik" + v-codrel no-error.*/
	find first t-anket where t-anket.kritcod = "iin" + v-codrel no-error.
    if not avail t-anket or t-anket.rescha[3] = "" then do:
      message skip " Запрос данных в ГЦВП по ИИН '" + t-anket.value1 + "' не был отправлен !" skip(1)
              view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
    end.
    else do:
      if num-entries(t-anket.rescha[3],";") = 1 then do:
        /* файл был, но ответ не импортировался */
        fname = entry(1,t-anket.rescha[3],";").

        v-dira = get-sysc-cha ("pkgcva").
        v-diri = get-sysc-cha ("pkgcvi").

        FILE-INFO:FILE-NAME = v-diri + fname.

      /*  find first gcvp where gcvp.nfile = substr(fname,5) exclusive-lock no-error .
        if avail gcvp and FILE-INFO:FILE-TYPE ne ? then gcvp.answ = FILE-INFO:FILE-SIZE.
        release gcvp.
       */

        IF FILE-INFO:FILE-TYPE = ? THEN do:
          message skip "Файл ответа " + fname + " из ГЦВП не пришел" skip(1)
           view-as alert-box button Ok title "Внимание!".
          return.
        end.

        IF FILE-INFO:FILE-SIZE = 0 THEN do:
          message skip "При приеме ответа " + fname + " из ГЦВП произошел сбой!" skip
                       "Повторите запрос в ГЦВП !" skip(1)
           view-as alert-box button Ok title "Внимание!".
           t-anket.rescha[3] = "".
          return.
        end.

      /*  unix silent value("cat " + v-diri + fname + " | win2koi > " + v-dira + fname).*/

        input from value(v-diri + fname).

        REPEAT on error undo, leave:
           create t-gcvp.
           import unformatted t-gcvp no-error.
           IF ERROR-STATUS:ERROR then do:
              run savelog("gcvpout","Ошибка импорта").
              return.
           END.
        END.
        input close.

        run savelog("gcvpout", "Принятие ответа из ГЦВП " + fname).

        find first t-anket where t-anket.kritcod = v-cod no-error.
		if avail t-anket then do:
			t-anket.value2 = fname.
			t-anket.value3 = "1".
			t-anket.value4 = "1".
		end.

        find first t-anket where t-anket.kritcod = "iin" + v-codrel no-error.
        for each t-gcvp.
           if trim(t-gcvp.txt) <> '' then t-anket.rescha[3] = t-anket.rescha[3] + ";" + t-gcvp.txt.
        end.
      end.

      v-gcvptxt = t-anket.rescha[3].
/*      if s-credtype = '4' /*карточки*/ then find first t-anket where t-anket.kritcod = "jobs1" no-lock no-error.
      else find first t-anket where t-anket.kritcod = "jobs" no-lock no-error.
*/

      find first t-anket where t-anket.kritcod = "jobs" no-lock no-error.
      if avail t-anket then run pkgcvprep2(v-gcvptxt, t-anket.value1).
                       else run pkgcvprep2(v-gcvptxt, "").

/*      find first t-anket where t-anket.kritcod = "sik" + v-codrel no-error.*/
    end.
  end.
end.


procedure pkage.
   def input parameter v-cod as char.
   def var v-limage as integer.
   def var v-age as integer init 0.
   def var v-codrel as char.

   find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
   find first t-anket where t-anket.kritcod = v-cod no-error.
   if not avail t-anket then do:
     create t-anket.
     assign t-anket.bank = s-ourbank
            t-anket.credtype = s-credtype
            t-anket.ln = int(pkkrit.ln)
            t-anket.kritcod = v-cod
            t-anket.value1 = trim(pkkrit.res[2]).
   end.
   t-anket.value2 = "".
   t-anket.value3 = "1".
   t-anket.value4 = "1".

   v-limage = get-pksysc-int ("limage").

   v-codrel = "".
   if length(v-cod) > length("age") then v-codrel = substr (v-cod, 4).
   find first t-anket where t-anket.kritcod = "bdt" + v-codrel no-error.
   if avail t-anket and t-anket.value1 <> ? then v-age = (g-today - date(t-anket.value1)) / 365.

   find first t-anket where t-anket.kritcod = v-cod no-error.

   if v-age >= v-limage then assign t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1]))
                                    t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
                        else assign t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1]))
                                    t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
end.

procedure pkage2.
   def input parameter v-cod as char.
   def var v-age as integer.
   def var v-rat as integer extent 2.
   def var v-spr as char.

   find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
   find first t-anket where t-anket.kritcod = "bdt" no-error.
   if not avail t-anket then return.


     v-age = (g-today - date(t-anket.value1)) / 365.
     v-rat = 0.

     if pkkrit.kritspr ne '' then do:
         if num-entries(pkkrit.kritspr) = 1 then v-spr = pkkrit.kritspr.
                                            else v-spr = entry(integer(s-credtype),pkkrit.kritspr).
     end.

     for each bookcod where bookcod.bookcod = v-spr no-lock:
       if entry(3,bookcod.name," ") = "..." then do:
         if v-age >= integer(entry(1,bookcod.name," ")) then do:
           v-rat[1] = integer(bookcod.info[1]).
           v-rat[2] = integer(bookcod.info[2]).
           leave.
         end.
       end.
       else do:
         if v-age >= integer(entry(1,bookcod.name," ")) and v-age <= integer(entry(3,bookcod.name," ")) then do:
           v-rat[1] = integer(bookcod.info[1]).
           v-rat[2] = integer(bookcod.info[2]).
           leave.
         end.
       end.
     end.

     if v-rat[1] <> 0 or v-rat[2] <> 0 then do:
       find first t-anket where t-anket.kritcod = v-cod no-error.
       if not avail t-anket then do:
         find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
         create t-anket.
         assign t-anket.bank = s-ourbank
                t-anket.credtype = s-credtype
                t-anket.ln = int(pkkrit.ln)
                t-anket.kritcod = v-cod
                t-anket.value1 = trim(pkkrit.res[2]).
       end.
       t-anket.value2 = "".
       t-anket.value3 = "1".
       t-anket.value4 = "1".

       t-anket.rating = v-rat[1].
       t-anket.resdec[5] = v-rat[2].
     end.
end.

/* за каждого несовершеннолетнего ребенка отнимаем рейтинг */
procedure pkchild16.
   def input parameter v-cod as char.
   def var v-kol as integer.

   find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
   find first t-anket where t-anket.kritcod = v-cod no-error.
   if not avail t-anket then do:
     create t-anket.
     assign t-anket.bank = s-ourbank
            t-anket.credtype = s-credtype
            t-anket.ln = int(pkkrit.ln)
            t-anket.kritcod = v-cod
            t-anket.value1 = trim(pkkrit.res[2]).
   end.
   t-anket.value2 = "".
   t-anket.value3 = "1".
   t-anket.value4 = "1".

   v-kol = integer (t-anket.value1).
   t-anket.rating = v-kol * integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
   t-anket.resdec[5] = v-kol * integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
end.

/* возраст автомашины - определяем по году выпуска */
procedure pkautoage.
  def input parameter v-cod as char.
  def var v-god as integer.
  def var v-age as integer.
  def var v-rat as integer.
  def var v-rat1 as integer init 0.
  def var v-sng as integer.
  def var v-sprcod as char.

  find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
  find first t-anket where t-anket.kritcod = v-cod no-error.
  if not avail t-anket then do:
    create t-anket.
    assign t-anket.bank = s-ourbank
           t-anket.credtype = s-credtype
           t-anket.ln = int(pkkrit.ln)
           t-anket.kritcod = v-cod
           t-anket.value1 = trim(pkkrit.res[2]).
  end.
  t-anket.value2 = "".
  t-anket.value3 = "1".
  t-anket.value4 = "1".

  v-rat = 0.
  v-sprcod = "".

  /* в зависимости от производителя авто берем соответствующее значение из экстента справочника */
  find first t-anket where t-anket.kritcod = "autoprod" no-error.
  if avail t-anket and t-anket.value1 <> "" then v-sng = integer(t-anket.value1).
  else v-sng = 1.

  if s-credtype = '4' and v-sng = 2  then return.

  find first t-anket where t-anket.kritcod = "autoy" no-error.

  if avail t-anket and trim(t-anket.value1) <> "" then do:

    v-age = year (g-today) - integer(t-anket.value1).
    for each bookcod where bookcod.bookcod = entry(integer(s-credtype),pkkrit.kritspr) no-lock:
      if entry (3, bookcod.name, " ") = "..." then do:
        v-rat = integer (bookcod.info[v-sng]).
        v-sprcod = bookcod.code.
        if s-credtype = '4' then v-rat1 = integer (bookcod.info[2]). /*соц рейтинг для карточек*/
        leave.
      end.
      else do:
        v-god = integer (entry (3, bookcod.name, " ")).
        if v-age <= v-god then do:
          v-rat = integer (bookcod.info[v-sng]).
          v-sprcod = bookcod.code.
          if s-credtype = '4' then v-rat1 = integer (bookcod.info[2]). /*соц рейтинг для карточек*/
          leave.
        end.
      end.
    end.
  end.
  else do:
    find first t-anket where t-anket.kritcod = "auto" no-error.
    if avail t-anket and trim(t-anket.value1) <> "" then do:
      find first bookcod where bookcod.bookcod = entry(integer(s-credtype),pkkrit.kritspr) and bookcod.code = '99' no-lock no-error.
      if avail bookcod then do:
         v-rat = integer (bookcod.info[v-sng]).
         v-sprcod = bookcod.code.
         if s-credtype = '4' then v-rat1 = integer (bookcod.info[2]). /*соц рейтинг для карточек*/
      end.
    end.
  end.

  find first t-anket where t-anket.kritcod = v-cod no-error.
  t-anket.value1 = v-sprcod.
  t-anket.rating = v-rat.
  t-anket.resdec[5] = v-rat1.
end.


procedure pknedvauto.
   def input parameter v-cod as char.
   def var myrat as integer init 0.

   /* имеется ли недвижимость в собственности */
   find first pkkrit where pkkrit.kritcod = "nedvstreet" no-lock no-error.
   find first t-anket where t-anket.kritcod = "nedvstreet" no-lock no-error.
   if avail t-anket then do:
     if (t-anket.rating <> 0 and t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1]))) or
        (t-anket.resdec[5] <> 0 and t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])))
     then myrat = myrat + 1.
   end.
   /* имеется ли авто в собственности */
   find first pkkrit where pkkrit.kritcod = "auto" no-lock no-error.
   find first t-anket where t-anket.kritcod = "auto" no-lock no-error.
   if avail t-anket then do:
     if (t-anket.rating <> 0 and t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1]))) or
        (t-anket.resdec[5] <> 0 and t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])))
     then myrat = myrat + 1.
   end.

   find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
   find first t-anket where t-anket.kritcod = v-cod no-error.
   if not avail t-anket then do:
     create t-anket.
     assign t-anket.bank = s-ourbank
            t-anket.credtype = s-credtype
            t-anket.ln = int(pkkrit.ln)
            t-anket.kritcod = v-cod
            t-anket.value1 = trim(pkkrit.res[2]).
   end.
   t-anket.value2 = "".
   t-anket.value3 = "1".
   t-anket.value4 = "1".

   if myrat = 2 then assign t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1]))
                            t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
                else assign t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1]))
                            t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
end.

/* рейтинг за стаж работы - определяем по внесенным данным (11.01.2004 nadejda, ТЗ 679) */
procedure pkstage.
   def input parameter v-cod as char.
   def var v-rate as integer extent 2.
   def var v-god as decimal init 0.
   def var v-mc as integer init 0.
   def var v-codrel as char.
   def var v-sprav as char.

   find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
   find first t-anket where t-anket.kritcod = v-cod no-error.
   if not avail t-anket then do:
     create t-anket.
     assign t-anket.bank = s-ourbank
            t-anket.credtype = s-credtype
            t-anket.ln = int(pkkrit.ln)
            t-anket.kritcod = v-cod
            t-anket.value1 = trim(pkkrit.res[2]).
   end.
   t-anket.value2 = "".
   t-anket.value3 = "1".
   t-anket.value4 = "1".

   v-codrel = "".
   if length(v-cod) > length("jobt") then v-codrel = substr (v-cod, 4).

   /* найти число лет стажа */
   find first t-anket where t-anket.kritcod = "jobtorgy" + v-codrel no-error.
   if avail t-anket and t-anket.value1 <> ? and trim(t-anket.value1) <> "" then v-god = integer(t-anket.value1).

   /* найти число месяцев стажа */
   find first t-anket where t-anket.kritcod = "jobtorgm" + v-codrel no-error.
   if avail t-anket and t-anket.value1 <> ? and trim(t-anket.value1) <> "" then v-mc = integer(t-anket.value1).

   find first t-anket where t-anket.kritcod = v-cod no-error.

   v-god = v-god + v-mc / 12.

   if v-god = 0 then do:
      t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
      t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.
   else do:
     v-rate[1] = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
     v-rate[2] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).

     if num-entries(pkkrit.kritspr) = 1 then
          v-sprav = pkkrit.kritspr .
     else v-sprav = entry(integer(s-credtype),pkkrit.kritspr) .

     find first bookcod where bookcod.bookcod = v-sprav and v-god <= integer(bookcod.code) no-lock no-error.
     if avail bookcod then do:
       v-rate[1] = integer (bookcod.info[1]).
       v-rate[2] = integer (bookcod.info[2]).
       t-anket.value1 = bookcod.code.
     end.
     else do:
       find last bookcod where bookcod.bookcod = v-sprav no-lock no-error.
       if avail bookcod then do:
         v-rate[1] = integer (bookcod.info[1]).
         v-rate[2] = integer (bookcod.info[2]).
         t-anket.value1 = bookcod.code.
       end.
     end.

     t-anket.rating = v-rate[1].
     t-anket.resdec[5] = v-rate[2].
   end.
end.


/* клиент нашего банка или нет - определяем по найденным данным, если хоть одно найдено */
procedure pkclntxb.
  def input parameter v-cod as char.
  def var v-client as logical.

  find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
  find first t-anket where t-anket.kritcod = v-cod no-error.
  if not avail t-anket then do:
    create t-anket.
    assign t-anket.bank = s-ourbank
           t-anket.credtype = s-credtype
           t-anket.ln = int(pkkrit.ln)
           t-anket.kritcod = v-cod
           t-anket.value1 = trim(pkkrit.res[2]).
  end.
  t-anket.value2 = "".
  t-anket.value3 = "1".
  t-anket.value4 = "1".

  find first t-anket where t-anket.kritcod = "ak34" no-error.
  v-client = (avail t-anket and t-anket.value1 <> "").

  if not v-client then do:
    find first t-anket where t-anket.kritcod = "acc1" no-error.
    v-client = (avail t-anket and t-anket.value2 <> "").
  end.

  if not v-client then do:
    find first t-anket where t-anket.kritcod = "acc2" no-error.
    v-client = (avail t-anket and t-anket.value2 <> "").
  end.

  find first t-anket where t-anket.kritcod = v-cod no-error.
  if v-client then
      assign t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1]))
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
              else
      assign t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1]))
             t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
end.


/* холост и нет детей < 16 - определяем по внесенным данным */
procedure pkfam1.
  def input parameter v-cod as char.
  def var v-client as logical.

  find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
  find first t-anket where t-anket.kritcod = v-cod no-error.
  if not avail t-anket then do:
    create t-anket.
    assign t-anket.bank = s-ourbank
           t-anket.credtype = s-credtype
           t-anket.ln = int(pkkrit.ln)
           t-anket.kritcod = v-cod
           t-anket.value1 = trim(pkkrit.res[2]).
  end.
  t-anket.value2 = "".
  t-anket.value3 = "1".
  t-anket.value4 = "1".

  find first t-anket where t-anket.kritcod = "family" no-error.
  v-client = (avail t-anket and lookup (t-anket.value1, "00,02,03") > 0).

  if v-client then do:
    find first t-anket where t-anket.kritcod = "child16" no-error.
    v-client = (avail t-anket and (t-anket.value2 = "") or (integer(t-anket.value2) = 0)).
  end.

  find first t-anket where t-anket.kritcod = v-cod no-error.
  if v-client then
       assign t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1]))
              t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
              else
       assign t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1]))
              t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
end.


procedure pkgcvpsum.
  def input parameter v-cod as char.
  def var v-sum as deci.
  def var v-suml as logical.
  def var v-nal as decimal init 0.
  def var v-gcvptxt as char.
  def var l-kred as integer.
  def var v-dohod as decimal no-undo.
  def var v-vichet as decimal no-undo.

  find first t-anket where t-anket.kritcod = "sik" no-error.
  if num-entries(t-anket.rescha[3],";") > 1 then do:
       l-kred = 0.

       v-gcvptxt = t-anket.rescha[3].

       find first t-anket where t-anket.kritcod = "jobs" no-lock no-error.

       /* 25.12.2003 nadejda - вызов программы анализа ответа ГЦВП */
       /*run pkanlgcvp (v-gcvptxt, t-anket.value1, output l-kred, output v-nal).*/

       /* чисты доход рассчитывается "начисленный - пенсионный - подоходный" */

       if t-anket.value1 = '50' or  t-anket.value1 = '60' then do:
         find first bookcod where bookcod.bookcod = "pkankkat" and bookcod.code = t-anket.value1 no-lock no-error.
           if avail bookcod then do:
             v-dohod = integer (bookcod.info[3]).
             v-vichet = integer (bookcod.info[4]).
             v-nal = decimal(entry(9, (entry(2, v-gcvptxt, ';')), '|')) * v-dohod * (100 - v-vichet) / 100.
           end.
       end.
       else
          /* чисты доход рассчитывается "начисленный - пенсионный - подоходный" */
          v-nal = decimal(entry(9, (entry(2, v-gcvptxt, ';')), '|')) * 8.1 + 975.2.


       find first t-anket where t-anket.kritcod = v-cod no-error.
       find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.
       t-anket.value1 = string(v-nal).
       t-anket.rescha[3] = string(l-kred).

       v-sum = v-nal.
         find first t-anket where  t-anket.kritcod = "jobpr2"  no-lock no-error.
         if avail t-anket and t-anket.value1 <> "" then do:
           find bookcod where bookcod.bookcod = "pkankdoh" and bookcod.code = t-anket.value1 no-lock no-error.
           if entry(3, bookcod.name, " ") = "..."
               then v-suml = decimal(entry(1, bookcod.name, " ")) < v-sum.
               else v-suml = decimal(entry(1, bookcod.name, " ")) <= v-sum and decimal(entry(3, bookcod.name, " ")) >= v-sum.
         end.
         else v-suml = false.

         find first t-anket where t-anket.kritcod = v-cod no-error.
         if v-suml then do:
                    t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
                    t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
                    t-anket.value2 = "Данные анкеты совпали".
                    t-anket.value3 = "1".
                    t-anket.value4 = "1".
                   end.
                   else do:
                    t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
                    t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
                    t-anket.value2 = "Данные анкеты не совпали".
                    t-anket.value3 = "0".
                    t-anket.value4 = "0".
                   end.
  end.
end.

/* Проведение проверки РНН организации */
procedure pkclnkorp.
  def input parameter v-cod as char.
  def var v-ankrnn as char init "no".
  def var v-is-client as logical.

  find first t-anket where t-anket.kritcod = "jobrnn" no-error.

   v-ankrnn = trim(t-anket.value1).

   run rnn-is-client (v-ankrnn, input-output v-is-client).

  find first t-anket where t-anket.kritcod = v-cod no-error.
  find first pkkrit where pkkrit.kritcod = v-cod no-lock no-error.


   if v-is-client then do:
       t-anket.value2 = "yes".
       t-anket.value3 = "1".
       t-anket.value4 = "1".
       t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
       t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
   end. else do:
       t-anket.value2 = "no".
       t-anket.value3 = "1".
       t-anket.value4 = "1".
       t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
       t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
   end.

end.

procedure pkcomment.
  def input parameter v-cod as char.
  def var v-comm as char.

  find first t-anket where t-anket.kritcod = v-cod no-error.
  if trim(t-anket.value1) <> '' then do:
    update skip(1) " " v-comm validate (trim(v-comm) <> '', " Введите замечания по анкете ")
           help "Введите данные (F1 - сохранение, F4 - отмена)" view-as editor size 70 by 10 " "
           skip(1) with no-labels title " Замечания менеджера по анкете " row 5 centered overlay frame fr.
    if trim(v-comm) <> '' then t-anket.value1 = t-anket.value1 + ' ' + trim(v-comm).
    t-anket.value3 = "1".
    t-anket.value4 = "1".
    t-anket.rating = 0.
    t-anket.resdec[5] = 0.
  end.
end.

procedure orgref.
  def input parameter v-cod as char.
  def var v-ref as logi no-undo.

  find first t-anket where t-anket.kritcod = "rnn" no-lock no-error.
  v-ref = (t-anket.rescha[1] <> '') and (t-anket.resdec[1] > 0).

  if v-ref then do:
    find first t-anket where t-anket.kritcod = v-cod no-error.
    if trim(t-anket.value1) <> '' then do:
        t-anket.value1 = ''.
        message "Анкета на рефинансирование кредита АО Метрокомбанк. Заполнение данного критерия недопустимо." view-as alert-box error.
    end.
  end.
  else assign t-anket.value3 = "1"
              t-anket.value4 = "1".

end.

procedure pkmainln.
  def input parameter v-cod as char.
  def var v-ref as logi no-undo.
  find first t-anket where t-anket.kritcod = v-cod exclusive-lock no-error.
  find pkanketa where pkanketa.bank = t-anket.bank and pkanketa.credtype = t-anket.credtype and pkanketa.ln = integer(t-anket.value1) no-lock no-error.
  if not avail pkanketa then do:
     message 'Не найдена анкета заемщика!' view-as alert-box title 'ВНИМАНИЕ'.
     t-anket.value2 = "Не найдена анкета!".
     t-anket.value3 = "0".
     t-anket.value4 = "0".
  end.
  else do:
     t-anket.value2 = "".
     t-anket.value3 = "1".
     t-anket.value4 = "1".

  end.
end.
