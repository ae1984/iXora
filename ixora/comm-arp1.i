/* comm-arp1.i
 * MODULE
        Коммунальные/налоговые платежи
 * DESCRIPTION
        Проверяет кассу (100100) на блокировку, проверяет разрешение на работу с Кассой в пути послу 18:00, предлагает выбор между 100100 и 100200 до 18:00
 * RUN
        включаемый фаил
 * CALLER
        comm-arp.p        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        19/05/2004 valery
 * CHANGES
        24/05/2004 valery убрал проверку из "CASOFC" на время 18:00, теперь если есть там РКО то was_casofc = true
        01/07/2005 kanat  добавил условие по 100200 для филиалов
        21/10/2005 sasco   - исправил проверку на 514 (кассу)
*/


define variable was_casofc as logical initial false.
define variable was_cassof as logical initial false.
/*define variable seltxb     as integer . */
define variable v-dep as char.

seltxb = comm-cod() .

find first depaccnt where depaccnt.depart = i_temp_dep no-lock no-error.
if avail depaccnt then do:
  s_dep_cash = GET-SYSC-CHA ("csptdp").
  if s_dep_cash = ? then s_dep_cash = "".

  /* Для малых РКО все остается по-старому */
  if lookup (string(depaccnt.depart), s_dep_cash) > 0 then do:
            s_account_a = ''. 
            s_account_b = '000061302'. 
  end.
  else do: 
    /* для крупных РКО и Центрального офиса */

    /* проверим на наличие РКО в списке для 100200 после 18:00 */
    def var time18 as int init 64800.  /*18:00*/

    find sysc where sysc.sysc = "CASOFC" no-lock no-error.
    if available sysc then do:

      time18 = sysc.inval.

      if (seltxb <> 2 and lookup (string(i_temp_dep), sysc.chval) > 0) /* valery 24/05/04 and time >= sysc.inval*/ then was_casofc = true. /*имеем право на работу по 100200 после 18:00*/

      if (seltxb = 2 and lookup (string(i_temp_dep), sysc.chval) >= 0) /* kanat 01/06/05 */ then was_casofc = true. 

    end.
    else do:
      message skip " Не найдена настройка CASOFC. Отмена операции. " skip(1) view-as alert-box title "". 
      return.
    end.

    find sysc where sysc.sysc = "CASVOD" no-lock no-error.
    if avail sysc then 
    do:

            if sysc.loval then 
            do: /*если касса блокирована*/

                    if was_casofc then /*если мы имеем право работать с 100200*/
                    do:

    /*                      message "Касса блокирована и мы имеем право работать с 100200".*/
                            s_account_a = ''. 
                            s_account_b = 'arp'. 
                    end.
                    else 
                    do:
    /*                      message "касса блокирована, и мы не имеем права работать".*/
                            message "Касса блокирована, дальнейшая работа не возможна".
                            return. /*выход*/
                    end.
            end.    
            else    /*если касса не блокированна*/
            do:
                    if  time >= time18 then /*текущее время больше 18:00*/
                    do:
                            if was_casofc then /*если мы имеем право работать с 100200*/
                            do:
    /*                              message "Касса не блокирована, текущее время больше 18:00, и мы имеем право работать с 100200".*/
                                    s_account_a = ''. 
                                    s_account_b = 'arp'. 
                            end.
                            else 
                            do:
    /*                              message "Касса не блокирована, текущее время больше 18:00, но мы имеем права работать с выбором".*/
                                    was_cassof = true. /*разрешено, предлагаем выбрать*/
                            end.
                    end.
                    else /*текущее время меньше 18:00*/
                    do:
                                            was_cassof = true. /*разрешено, предлагаем выбрать*/
                    end.
            end.
    end.
    else do:
      message skip " Не найдена настройка CASVOD. Отмена операции." skip(1) view-as alert-box title "". 
      return.
    end.



    if was_cassof then  /*если разрешено работать через 100200 или 100100 между 17:00 и 18:00*/
    do:
    /*выбираем*/
                            run sel('Укажите счет кассы', 'Касса        100100|Касса в пути 100200').
                            if return-value = '1' then do:
                              s_account_a = '100100'. 
                              s_account_b = ''. 
                            end.
                            else do:
                              s_account_a = ''. 
                              s_account_b = 'arp'. 
                            end.
    end.

    /* поискать кассу в пути свою для ЦО и каждого РКО */
    if s_account_b = "arp" then do:

      find sysc where sysc.sysc = "904kas" no-lock no-error.
      if not avail sysc then do:
        message skip " Не настроен счет кассы в пути по ГК 100200 (настройка 904kas)!" 
                skip(1) view-as alert-box title " ОШИБКА ! ".
        return.
      end.

      FIND ofc where ofc.ofc = g-ofc no-lock no-error .
      if i_temp_dep = 1 and ofc.titcd <> "514" then do:
        s_account_b = sysc.chval.
      end.
      else do:
        for each arp where arp.gl = sysc.inval no-lock:
          if arp.crc <> 1 then next.

          find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and
                             sub-cod.acc = arp.arp no-lock no-error.
          if not avail sub-cod or sub-cod.ccode <> "obmen1002" then next.
           
          find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and
                             sub-cod.acc = arp.arp no-lock no-error.
          if not avail sub-cod then next.
          /*
          if not avail sub-cod or (substr(sub-cod.ccode, 2, 2) <> string(i_temp_dep, "99") and sub-cod.ccode <> "514") then next.
          */
          if ofc.titcd = "514" then  /* кассир ЦО */
          do: 
               if sub-cod.ccode <> "514" then next.  /* наша каса? */
          end.
          else do: /* кассир не из ЦО */
               if substr(sub-cod.ccode, 2, 2) <> string(i_temp_dep, "99") then next. /* РКО? */
          end.


          s_account_b = arp.arp.
          leave.
        end.

        if s_account_b = "arp" then do:
          message skip " Не настроен счет кассы в пути 100200 для департамента данного офицера!" 
                  skip(1) view-as alert-box title " ОШИБКА ! ".
          undo, return.
        end.
      end.
    end.  /* поиск АРП-счета кассы в пути */

  end. /* поиск в списке малых РКО */
end. /* avail depaccnt */


