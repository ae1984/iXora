/* r-cdmato.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        02/12/04 sasco добавил Г/К
        27.01.10 marinav - расширение поля счета до 20 знаков
*/

 /*  r-cdmato.p
     Отчет: %% по депозитам, 
     срок возврата которых приходится на указанный период времени
     изменения от 04.04.01 */
     
 def shared var s-aaa like aaa.aaa.
 def shared var s-cif like cif.cif.
 def var m-begday as date.
 def var m-endday as date.
 def var vdaytm as int.
 def var vdays as int.
 def var mbal like aaa.opnamt.
 def var curbal like aaa.opnamt.
 def var vtitle1 as cha form "x(132)".
 def var vtitle2 like vtitle1.
 def var m-rate like aaa.rate.
 def var s-intday as int.
 def var m-int as int.
 def var i as int initial 0.
 def var j as int initial 0.
 def var m-str1 as char .
 def var m-str2 as char.
 def var v-inc as int.
 def var v-accrued like aaa.accrued.
 def var m-sum like glbal.bal.
 def var m-sum0 like glbal.bal.
 def var m-sum1 like glbal.bal.
 def var v-tmpbal like glbal.bal.
 def var v-intbal like glbal.bal.
 def var v-min like glbal.bal.
 def var v-max like glbal.bal.
 def var m-first as log initial false.
 def stream m-out.

{mainhead.i}
{functions-def.i}
m-begday = g-today.
m-endday = g-today.

display
   m-begday label " с "
   m-endday label " по "
   with row 8 centered  side-labels frame opt title " Введите период: " .
         
   update m-begday
          with frame opt.
   update m-endday validate(m-endday >= m-begday,
          "Должно быть: Начало <= Конец ")
          with frame opt.
 
 hide frame opt.
                     
 display '   Ждите...   '  with row 5 frame ww centered .
                     

output stream m-out to rpt.img.

put stream m-out
FirstLine( 1, 1 ) format 'x(127)' skip(1)
'                          '
'ДЕПОЗИТЫ, СРОК ОКОНЧАНИЯ КОТОРЫХ ПРИХОДИТСЯ '  skip
'                            '
'на период с ' string(m-begday)  ' по '  string(m-endday) skip(1)
FirstLine( 2, 1 ) format 'x(127)' skip.
put stream m-out  fill( '-', 127 ) format 'x(127)'  skip.
put stream m-out
'  Счет              '
'  Г/К ' 
'  Клиент '
'Вал. '
' Сумма вклада '
' % ставка'
'       Остаток '
'      Начисл.%% '
'   Остаток + %% ' 
' Начало '
' Окончание '
skip.
 put stream m-out  fill( '-', 127 ) format 'x(127)'  skip(1).

for each aaa where aaa.sta <> "C"
               and aaa.expdt ge m-begday
               and aaa.expdt le m-endday
               and aaa.dr[1] ne  aaa.cr[1]
               no-lock break by lgr:
    m-rate = 0.
    v-accrued = 0.
    m-sum = aaa.cr[1] - aaa.dr[1].
    s-intday = aaa.expdt - g-today.
    find lgr where lgr.lgr = aaa.lgr no-lock no-error.
 
   if available pri then do:
    if lgr.pri = "F" then do:  /* ставка фиксированная */
       if lookaaa then m-rate = aaa.rate. 
                  else m-rate = lgr.rate.
       if s-intday >= 0  then
           v-accrued = m-sum * m-rate * s-intday / 100.00 / lgr.base.
    end.
    else do:
       find pri where pri.pri eq lgr.pri no-lock no-error.
         if pri.itype eq 1 then do:
            m-rate = pri.rate + lgr.rate.
            if s-intday >= 0 then
              v-accrued = m-sum * m-rate * s-intday / 100.00 / lgr.base.
         end.
         if s-intday >= 0  and 
            pri.itype ne 1 then do:
             m-int = 1.
             repeat while (m-int <= 6) and (pri.tlimit[m-int] >= m-sum) :
                 m-int = m-int + 1.
             end.
             v-tmpbal = m-sum.
             v-accrued = 0.
              if m-int >= 7 then  m-int = 6.
               repeat v-inc = m-int to 1 by -1:
                 v-max = pri.tlimit[v-inc].

                 if v-inc gt 1 then 
                    v-min = pri.tlimit[v-inc - 1].
                 else v-min = 0.
                 if v-tmpbal gt v-min and v-tmpbal le v-max then do:
                    if pri.ttype[v-inc] eq 1 then do: /* Tiered */
                       v-intbal = v-tmpbal.
                       v-tmpbal = 0.
                    end.
                    else if pri.ttype[v-inc] eq 2 then do: /* Interval */
                         v-intbal = v-tmpbal - v-min.
                         v-tmpbal = v-min.
                    end.
                    v-accrued = v-accrued + s-intday * v-intbal
                              * pri.trate[v-inc] / (lgr.base * 100).
                 end. /* In the range */
                 if v-tmpbal eq 0 then leave.
               end. /* repeat */
         end. /* if  pri.itype ne 1 */
    end.  /* else do */
   end. /*if available pri */
    /* не учитывается комплексное начисление процентов */
    find crc where crc.crc = aaa.crc no-lock no-error.
    put stream m-out unformatted 
             aaa.aaa format "x(20)" ' '
             aaa.gl ' '
             aaa.cif ' '
             crc.code ' '
             aaa.opnamt format "z,zzz,zzz,zz9.99"  
             m-rate format "zz9.99" 
             m-sum  format "z,zzz,zzz,zz9.99" 
             (aaa.accrued + v-accrued) format "z,zzz,zzz,zz9.99"
             (m-sum + aaa.accrued + v-accrued) format "z,zzz,zzz,zz9.99" ' '
             aaa.regdt ' '
             aaa.expdt
             skip.
    m-sum0 = m-sum0 + m-sum.
    m-sum1 = m-sum1 + (aaa.accrued + v-accrued).

    if last-of(aaa.lgr)  then do:
        put stream m-out unformatted 
            fill("-",127) format "x(127)" skip
            'ИТОГО - группа ' 
            aaa.lgr ' ' 
            lgr.des format 'x(16)'
            fill(" ",26) format "x(26)"
            m-sum0 format "z,zzz,zzz,zz9.99"
            m-sum1 format "z,zzz,zzz,zz9.99"
            (m-sum0 + m-sum1) format "z,zzz,zzz,zz9.99" skip(2)
            skip.
        m-sum0 = 0.
        m-sum1 = 0.
       /* m-first = false.  */
    end.


/*   if i = j then do:
      put stream m-out unformatted
          m-str2 format "x(20)"
          i 
          skip.
        j = j + 100.
    end. 
    i = i + 1.
    pause 0. */
end.
output stream m-out close.

if  not g-batch then do:
    pause 0 before-hide .
    run menu-prt( 'rpt.img' ).
    pause before-hide.
end.
{functions-end.i}

return.
