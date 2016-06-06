﻿/* pkdebts.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Должники на контроле
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        4-14-6
 * AUTHOR
        01.02.2004 nadejda
 * CHANGES
        05.04.2004 tsoy?   - изменил формирование списка задолжников добавил статус и пр.
        12.04.2004 tsoy    - изменил автоматическую установку статусов
        13.04.2004 nadejda - добавила запись времени в substs
        14.04.2004 tsoy    - изменил условия для авт. уст статуса
        14.04.2004 tsoy    - только быстрые деньги и быстрые кредиты, остальные отсекаем
        20.05.2004 tsoy    - не передаю никакого прарметра в pkcash.i
        06/10/2004 madiyar - перекомпиляция
        16/08/2005 madiyar - добавил в задолженность долг по комиссии
        05/10/2005 madiyar - отредактировал запросы для ускорения загрузки модуля
        10/10/2005 madiyar - долг по комиссии добавлялся не совсем корректно, исправил
        13/10/2005 madiyar - добавилось поле t-pkdebt.balcom
        21/10/2005 madiyar - небольшая оптимизация
        24/02/2006 madiyar - добавилась обработка результата "leg" - передан в Юридический департамент
        05/04/2006 madiyar - добавил вид "KP"
        16/05/2006 madiyar - добавил статус "Z" - списанные за баланс
        14/06/2006 madiyar - небольшие изменения
        02/08/2006 madiyar - добавил "КПро" (кол-во просрочек)
        24/10/2006 madiyar - выборка из pkdebt - добавил условие pkdebt.bank = s-ourbank
        07/11/2006 madiyar - в Алматы убираем казпочтовые кредиты филиалов; исправил проблему с днями просрочки
        17/11/06 Natalya D. - добавлен учет сумм на 4 и 5 уровнях.
        25/05/2007 madiyar - убрал лишнее (казпочта)
        07/08/2008 madiyar - выводились ошибки по записям pkdebt, относящимся к МКО, исправил
        13/11/2008 madiyar - телефон в письмах - храним в sysc.sysc = "pklets"
        04/02/2010 madiyar - перекомпиляция в связи с добавление поля в таблице londebt
        08/02/2010 madiyar - перекомпиляция
*/


{mainhead.i}
{pk.i new}

def new shared temp-table t-pkdebt like pkdebt
  field name      as   char
  field checkdt   as   date
  field yessendlt as   char
  field bal1      like lon.opnamt   /* основной долг */
  field bal2      like lon.opnamt   /* проценты      */
  field balpen    like lon.opnamt   /* штрафы        */
  field balcom    like lon.opnamt   /* комиссия за вед. счета */
  field bal3      like lon.opnamt   /* общая сумма задолженности */
  field balz1     like lon.opnamt   /* списанный ОД */
  field balz2     like lon.opnamt   /* списанные % */
  field balzpen   like lon.opnamt   /* списанные штрафы */
  field bal4      like lon.opnamt   /*4уровень*/
  field bal5      like lon.opnamt   /*5уровень*/
  field balmon    like lon.opnamt
  field aaabal    like lon.opnamt
  field crc       like lon.crc
  field lastlt    as   char
  field lastltdt  as   date
  field roll      as   integer
  field stype     as   char
  field duedt     like lon.duedt
  field lgrfdt    as date
  field expdt     as date
  field eday      as integer
  field prkol     as integer.

def new shared temp-table t-debt like t-pkdebt.

def new shared var s-lettersign as char.
def new shared var s-letterphone as char.

define variable datums as date no-undo format "99/99/9999" label "На".
def var v-select as integer no-undo.

message " Формируется список задолжников на сегодняшний день...".
/* файл подписи */
def var v-dcsign as char no-undo.
find sysc where sysc.sysc = "pklets" no-lock no-error.

/* если настройка есть и yes - факсимиле, нет - подпись живая */
if avail sysc and sysc.loval then do:
    v-dcsign = entry(1,sysc.chval).
    s-lettersign = "<IMG border=""0"" src=""" + v-dcsign + """ width=""180"" height=""60"" v:shapes=""_x0000_s1026"">".
    if num-entries(sysc.chval) > 1 then s-letterphone = entry(2,sysc.chval).
end.
else v-dcsign = "&nbsp;".


/* собрать список задолжников */
datums = g-today.

do:
  {pkcash.i}
end.


for each wrk where (wrk.bal1 + wrk.bal2 + wrk.bal3 + wrk.com_acc + wrk.bal13 + wrk.bal14 + wrk.bal30) > 0.


    find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = wrk.lon use-index banklon no-lock no-error.
    if avail pkanketa then do:

      find first pkdebt where pkdebt.bank = s-ourbank and pkdebt.lon = wrk.lon exclusive-lock no-error.

      if not avail pkdebt then do:
        create pkdebt.
        assign  pkdebt.bank       = s-ourbank
                pkdebt.credtype   = pkanketa.credtype
                pkdebt.ln         = pkanketa.ln
                pkdebt.lon        = wrk.lon
                pkdebt.sumdebt    = wrk.bal1 + wrk.bal2 + wrk.bal3 + wrk.com_acc
                pkdebt.days       = wrk.dt1
                pkdebt.sumacc     = wrk.aaabal
                pkdebt.ofc        = g-ofc
                pkdebt.stsdt      = g-today
                pkdebt.cif        = wrk.cif.

        if wrk.bal13 + wrk.bal14 + wrk.bal30 > 0 then do:
          pkdebt.sts = "Z".
          pkdebt.days = 0.
        end.
        else pkdebt.sts = "N".

        create substs.
        assign substs.sub = "dbt"
               substs.acc = pkdebt.lon
               substs.sts = pkdebt.sts
               substs.who = g-ofc
               substs.rdt = g-today.
        substs.rtim = time.
      end.
      else do:
         if wrk.bal13 + wrk.bal14 + wrk.bal30 > 0 then do:
                  assign pkdebt.sumdebt    = wrk.bal1 + wrk.bal2 + wrk.bal3 + wrk.com_acc + wrk.bal13 + wrk.bal14 + wrk.bal30
                         pkdebt.days       = 0
                         pkdebt.sumacc     = wrk.aaabal
                         pkdebt.ofc        = g-ofc
                         pkdebt.stsdt      = g-today
                         pkdebt.cif        = wrk.cif.
                   if pkdebt.sts <> "Z" then do:
                     pkdebt.sts = "Z".
                     create substs.
                     assign substs.sub = "dbt"
                            substs.acc = pkdebt.lon
                            substs.sts = pkdebt.sts
                            substs.who = g-ofc
                            substs.rdt = g-today
                            substs.rtim = time.
                   end.
         end.
         else do:
            assign pkdebt.sumdebt    = wrk.bal1 + wrk.bal2 + wrk.bal3 + wrk.com_acc + wrk.bal13 + wrk.bal14 + wrk.bal30
                   pkdebt.days       = wrk.dt1
                   pkdebt.sumacc     = wrk.aaabal
                   pkdebt.ofc        = g-ofc.
            if pkdebt.sts = "C" then do:
                   assign pkdebt.sts        = "N"
                          pkdebt.stsdt      = g-today.

                   create substs.
                   assign substs.sub = "dbt"
                          substs.acc = pkdebt.lon
                          substs.sts = pkdebt.sts
                          substs.who = g-ofc
                          substs.rdt = g-today.
                   substs.rtim = time.
            end.
         end.
      end.
    end.
end.
release pkdebt.

for each pkdebt where pkdebt.bank = s-ourbank and pkdebt.sts <> "C" exclusive-lock:

    find first lon where lon.lon = pkdebt.lon no-lock no-error.
    if not avail lon then next.

    find first wrk where wrk.lon = pkdebt.lon no-lock no-error.
    if not avail wrk then do:
        pkdebt.sts = "C".
        pkdebt.stsdt = g-today.
        create substs.
        assign substs.sub = "dbt"
               substs.acc = pkdebt.lon
               substs.sts = pkdebt.sts
               substs.who = g-ofc
               substs.rdt = g-today
               substs.rtim = time.
        next.
    end.

    if pkdebt.sts <> "Z" then do:
       find first pkdebtdat where pkdebtdat.bank = s-ourbank and pkdebtdat.lon = pkdebt.lon and pkdebtdat.rdt >= (g-today - pkdebt.days) use-index lonrdt no-lock no-error.
       if avail pkdebtdat then do:
             pkdebt.sts = "K".

             find last pkdebtdat where pkdebtdat.bank = s-ourbank
                                      and pkdebtdat.lon = pkdebt.lon
                                      and pkdebtdat.rdt >= (g-today - pkdebt.days) /*lnsch.stdat */
                                      and pkdebtdat.rdt <= g-today
                                      and (pkdebtdat.result = "part" or pkdebtdat.result = "secu" or pkdebtdat.result = "leg") use-index lonrdt no-lock no-error.
              if avail pkdebtdat then do:
                 if pkdebtdat.result = "part" then pkdebt.sts = "K,P".
                 else if pkdebtdat.result = "secu" then pkdebt.sts = "K,S".
                 else if pkdebtdat.result = "leg" then pkdebt.sts = "K,L".
              end.

       end.
       else pkdebt.sts = "N".
    end. /* if pkdebt.sts <> "Z" */

    create t-pkdebt.
    buffer-copy pkdebt to t-pkdebt.

    if avail lnsch then t-pkdebt.lgrfdt = lnsch.stdat.

    find cif where cif.cif = pkdebt.cif no-lock no-error.
    t-pkdebt.name = cif.name.

    find last pkdebtdat where pkdebtdat.bank = s-ourbank and pkdebtdat.lon = pkdebt.lon use-index lonrdt no-lock no-error.
    if avail pkdebtdat then t-pkdebt.checkdt = pkdebtdat.checkdt.

    assign
    t-pkdebt.bal1    = wrk.bal3    /*ОД*/
    t-pkdebt.bal2    = wrk.bal2    /*%*/
    t-pkdebt.bal3    = wrk.bal1    /*Штраф*/
    t-pkdebt.balpen  = wrk.bal1    /*Штраф*/
    t-pkdebt.balcom  = wrk.com_acc /*комиссия*/
    t-pkdebt.balz1   = wrk.bal13   /*списОД*/
    t-pkdebt.balz2   = wrk.bal14   /*спис%*/
    t-pkdebt.balzpen = wrk.bal30   /*списШтраф*/
    t-pkdebt.bal4    = wrk.bal4   /*4уровень*/
    t-pkdebt.bal5    = wrk.bal5   /*5уровень*/
    t-pkdebt.balmon  = wrk.balmon
    t-pkdebt.aaabal  = wrk.aaabal
    t-pkdebt.expdt   = wrk.expdt
    t-pkdebt.eday    = wrk.day
    t-pkdebt.prkol   = wrk.prkol.


    find first lon where lon.lon = pkdebt.lon no-lock no-error.
    if avail lon then do:
         t-pkdebt.crc     = lon.crc.
         t-pkdebt.duedt   = lon.duedt.
    end.
    else do:
         t-pkdebt.crc     = 1.
    end.

    t-pkdebt.stype = wrk.stype.

    find last letters where letters.bank = s-ourbank and letters.ref = t-pkdebt.lon no-lock use-index refrdt no-error.
    if avail letters then do:
      assign t-pkdebt.lastlt   = letters.docnum
             t-pkdebt.lastltdt = letters.rdt
             t-pkdebt.roll     = letters.roll.
    end.
    else
      assign t-pkdebt.lastlt   = ""
             t-pkdebt.lastltdt = ?
             t-pkdebt.roll     = 0.

end.
release pkdebt.

v-credtype = "".
hide frame f-param.
hide message no-pause.

repeat:
  v-select = 0.
  run sel2 (" МОНИТОРИНГ ДОЛЖНИКОВ ", " 1. Список задолжников | 2. Справочники | 3. Отчеты |    ВЫХОД ", output v-select).

  if v-select = 0 then return.

  case v-select:
    when 1 then run pkdebt1.
    when 2 then run pkdebtsprav.
    when 3 then run pkdebtrep.
    when 4 then return.
  end.
end.