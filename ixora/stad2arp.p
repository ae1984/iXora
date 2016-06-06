/* stad2arp.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        stadsofp.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        27/10/03 kanat
 * CHANGES
        11/11/03 kanat - кассир зачисляет только на кассу
        24/03/04 kanat - добавил проверку по недостачам кассиров при зачислении на АРП счета
        04.03.2005 kanat - добавил условия по АРП счетам для филиалов
        04.03.2005 kanat - добавил условия по АРП счетам для филиалов
        06.05.2005 kanat - добавил новое условие по предварительно инкассированным квитанциям
        11.04.2005 kanat - дополнительно инкассированные кассы заисляются со  специального АРП счета
        12.04.2005 kanat - добавил no-lock и no-error
        14.04.2005 kanat - дополнительное инкассирование только для ЦО
        18/08/2005 kanat - убрал формирование операционных ордеров т.к. у менеджеров в конце зачислений формируется единый прих. ордер
        24/05/2006 marinav  - добавлен параметр даты факт приема платежа
        31/08/2006 u00568 Evgeniy - по тз 439 от 24/08/2006  объединил все вопросы в один.
                                  + расписал откат танзакции чтобы было красиво
                                  + убрал дублирующиеся участки кода
                                  + оптимизировал по производительности + по читаемости
        01/09/2006 u00568 Evgeniy - ошибка зачисления перелимита
*/


{comm-txb.i}
{yes-no.i}

def input parameter dat as date.
def input parameter uu as char.

def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}
{deparp.i}
{sysc.i}

define temp-table tCommonpl like commonpl.
/*define temp-table tt_Commonpl like commonpl.*/


def shared var g-today as date.
def new shared var s-jh like jh.jh.
def var s-arp as char.
def var tsum as decimal.
def var tsum_wc as decimal.
def var cho as logical init false.

def var i_temp_dep as integer.
def var s_dep_cash as char.

def var s_account_a as char.
def var s_account_b as char.

def var selarp  as char format "x(9)" init "".
def var selgrp  as integer.

def var v-kaslkm as char.
def var str_mes as char init '' no-undo.
def var i as int init 0 no-undo.
def var ret as char init '' no-undo.

def var tt_sums_count as int init 0 no-undo.

define temp-table tt_sums
  field sum as decimal
  field arp as char
  field grp  as integer
  field sum_wc as decimal.

if seltxb = 0 then do:
  find first sysc where sysc.sysc = "KASLKM" no-lock no-error.
  if avail sysc then
    v-kaslkm = trim(sysc.chval).
  else do:
    message "Отсутствует запись sysc.chval = KASLKM" view-as alert-box title "Внимание".
    return.
  end.
end.

if get-dep(uu, dat) = ? then do:
    message "Неверное имя кассира" VIEW-AS ALERT-BOX.
    return.
end.
    
if deparp(get-dep(uu, dat)) = ? then do:
    message "Не настроен транзитный счет департамента" VIEW-AS ALERT-BOX.
    return.
end.

/* --------- kanat зачисление на кассу в пути для департаментов из sysc.sysc = "csptdp" ----------- */

/*
i_temp_dep = int (get-dep (uu, dat)).


find first depaccnt where depaccnt.depart = i_temp_dep no-lock no-error.
if avail depaccnt then do:

  s_dep_cash = GET-SYSC-CHA ("csptdp").
  if s_dep_cash = ? then s_dep_cash = "".

if lookup (string(depaccnt.depart), s_dep_cash) > 0 then do:
            s_account_a = ''.
            s_account_b = '000061302'.
end.
else do:
            s_account_a = '100100'.
            s_account_b = ''.
end.
end.
*/



/* ------------------------------------------------------------------------------------------------- */
/*
            if return-value = '1' then '100100' else '',
            if return-value = '1' then '' else '000061302',
*/


if seltxb = 1 then do:
     assign s_account_a = ''
            s_account_b = '150076778'.
end.

if seltxb = 2 then do:
     assign s_account_a = ''
            s_account_b = '250076676'.
end.




for each commonpl no-lock where
                        commonpl.date = dat
                    and commonpl.uid = uu
                    and commonpl.txb = seltxb
                    and commonpl.joudoc = ?
                    and commonpl.rmzdoc = ?
                    and commonpl.deluid = ?
                    and commonpl.deldate = ?
                    and commonpl.chval[2] <> "1"
                    and commonpl.grp <> 4
                    and commonpl.grp <> 10
                  break by Commonpl.arp.
  if first-of(Commonpl.arp) then do:
    CREATE tCommonpl.
    buffer-copy commonpl to tCommonpl.
  end.
end.

for each commonpl no-lock where
                        commonpl.date = dat
                    and commonpl.uid = uu
                    and commonpl.txb = seltxb
                    and commonpl.joudoc = ?
                    and commonpl.rmzdoc = ?
                    and commonpl.deluid = ?
                    and commonpl.deldate = ?
                    and commonpl.chval[2] = "1"
                    and commonpl.grp <> 4
                    and commonpl.grp <> 10
                  break by Commonpl.arp.
  if first-of(Commonpl.arp) then do:
    CREATE tCommonpl.
    buffer-copy commonpl to tCommonpl.
    /*CREATE tt_Commonpl.
    buffer-copy commonpl to tt_Commonpl.*/
  end.
end.



/*---------------------------------------------------------------------------*/

do i = 1 to 2 :

  /* i = 1 НЕ предварительно инкассированные*/
  /* i = 2    предварительно инкассированные*/

  if seltxb = 0 then do:
    if i = 1 then do:
      s_account_a = '100100'.
      s_account_b = ''.
    end. else do:
      s_account_a = ''.
      s_account_b = v-kaslkm.
    end.
  end.

  for each tt_sums.
    delete tt_sums.
  end.

  tt_sums_count = 0.
  for each tCommonpl where (tCommonpl.chval[2] <> "1") = (i = 1) :
      find first commonls where commonls.arp = tCommonpl.arp
                            and commonls.grp = tCommonpl.grp
                         no-lock no-error.
      if avail commonls then do:
        selarp = commonls.arp.
        selgrp = commonls.grp.
      end. else
        next.

      tsum = 0.
      tsum_wc = 0.

      for each commonpl where commonpl.txb    = seltxb and
                              commonpl.date   = dat    and
                              commonpl.joudoc = ?      and
                              commonpl.uid    = uu     and
                              commonpl.deluid = ?      and
                              commonpl.arp    = selarp and
                              commonpl.grp    = selgrp and
                              (commonpl.chval[2] <> "1") = ( i = 1 )
                            no-lock:
        ACCUMULATE commonpl.comsum + commonpl.sum (total).
        ACCUMULATE commonpl.sum (total).
      end.
      tsum = ( accum total commonpl.comsum + commonpl.sum ).
      tsum_wc = ( accum total commonpl.sum ).
      if tsum <> 0 then do:
        CREATE tt_sums.
        tt_sums.arp = selarp.
        tt_sums.grp = selgrp.
        tt_sums.sum = tsum.
        tt_sums.sum_wc = tsum_wc.
        tt_sums_count = tt_sums_count + 1.
      end.
  end.
  if tt_sums_count = 0 then next.

  if i = 1 then
    str_mes = "Сделать зачисление НА ARP в тенге?".
  else
    str_mes ="Зачислить С АРП в тенге?".

  tt_sums_count = 0.
  for each tt_sums break by tt_sums.arp:
    tt_sums_count = tt_sums_count + 1.
    if i = 1 then
      str_mes = str_mes + '~n АРП ' + tt_sums.arp + ' - сумма ' + string(tt_sums.sum).
    else
      str_mes = str_mes + '~n АРП ' + v-kaslkm + " на " + tt_sums.arp + " сумму " + string(tt_sums.sum).

    if tt_sums_count = 10 then do:
      message str_mes + '~n вывожу первые 10 счетов ~n это ограничение размеров окна.' view-as alert-box title "Внимание".
      str_mes = ''.
      tt_sums_count = 0.
    end.
  end.

  if not yes-no("!Вопрос!", str_mes) then do:
    if yes-no("Вопрос!", "Почистить реестр?") then do:
      /*чистим реестр*/.
      run commondel.
      return.
    end.
    next.
  end.

  m1:
  do transaction:
    for each tt_sums ON error UNDO m1:
      find first commonls where commonls.txb = seltxb
                            and commonls.arp = tt_sums.arp
                            and commonls.visible = yes
                            and commonls.grp = tt_sums.grp
                          no-lock use-index type no-error.

      run trx(
        6,
        tt_sums.sum,
        1,
        s_account_a, /*if return-value = '1' then '100100' else '',*/
        s_account_b, /*if return-value = '1' then '' else '000061302',*/
        '',
        tt_sums.arp,
        'Зачисление на транзитный счет',
        '14',commonls.kbe,'856'
      ).

      if return-value = '' then undo, return.
      s-jh = int(return-value).
      run setcsymb (s-jh, commonls.symb).
      run jou.

      if return-value begins "Not cash" then do:
          message "Возможно, что произошла ошибка при зачислении!" skip "свяжитесь с Департаментом Информационных Технологий"
             view-as alert-box title "ВНИМАНИЕ".
          undo m1, return.
      end.
      if return-value = "" then undo, return.

      for each commonpl where commonpl.txb = seltxb
                          and commonpl.date = dat
                          and commonpl.arp = tt_sums.arp
                          and commonpl.joudoc = ?
                          and (commonpl.chval[2] <> "1") = (i = 1)
                          and commonpl.uid = uu
                          and commonpl.deluid = ?
                          and commonpl.grp = tt_sums.grp
                        exclusive-lock ON error UNDO m1:
        assign commonpl.joudoc = return-value.
        ACCUMULATE commonpl.comsum + commonpl.sum (total).
      end.
      tsum = ( accum total commonpl.comsum + commonpl.sum ).

      if tt_sums.sum <> tsum then  do:
        message "Произошла ошибка при зачислении!" skip "зачисленная jou-сумма(" + string(tt_sums.sum) + ") не равна сумме по реестру(" + string(tsum) + ")!!!"
             view-as alert-box title "ВНИМАНИЕ".
        return error.
      end.

      /*
      run vou_import.
      */

      find first comm.txb where comm.txb.txb = seltxb
                            and comm.txb.visible
                            and comm.txb.consolid
                          no-lock no-error.
      if comm.txb.city <> seltxb then do:
        find first cmp no-lock.
                    run commpl(
                         seltxb,
                         tt_sums.sum_wc,
                         deparp(get-dep(uu, dat)),
                         "TXB" + string(comm.txb.city,"99"),
                         /*  comm.txb.commarp, */
                         tt_sums.arp,
                         0,
                         no,
                         trim(cmp.name),
                         cmp.addr[2],
                       /*"919",
                         "14",
                         "14", */
                         commonls.knp,
                         commonls.kod,
                         commonls.kbe,
                         'Зачисление на транзитный счет коммун.пл.',
                         "1P",
                         1,
                         5,
                         "",
                         "",
                         dat).
        for each commonpl where commonpl.txb = seltxb
                            and commonpl.date = dat
                            and commonpl.arp = tt_sums.arp
                            and commonpl.rmzdoc = ?
                            and (commonpl.chval[2] <> "1") = (i = 1)
                            and commonpl.uid = uu
                            and commonpl.deluid = ?
                            and commonpl.grp = tt_sums.grp
                            and commonpl.joudoc <> ?
                          exclusive-lock ON error UNDO m1:
          assign commonpl.rmzdoc = return-value.
          ACCUMULATE commonpl.sum (total).
        end.
        tsum_wc = ( accum total commonpl.sum ).
        if tt_sums.sum_wc <> tsum_wc then  do:
          message "Произошла ошибка при зачислении!" skip "зачисленная rmz-сумма(" + string(tt_sums.sum_wc) + ") не равна сумме по реестру (" + string(tsum_wc) + ")!!!"
             view-as alert-box title "ВНИМАНИЕ".
          return error.
        end.
      end.
    end. /* for each  ... */
  end. /* do transaction */
end. /*do*/
