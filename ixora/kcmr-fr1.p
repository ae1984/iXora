/* kcmr-fr1.p
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        11.05.2004 nadejda - считать платежи ТОЛЬКО сегодняшней даты опердня
        21.04.2005 kanat - проверка на очереди DIRIN - очереди входящих платежей для ПКО
        22.04.2005 kanat - добавил проверки на формы собств. платежей на очереди DIRIN
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
*/

/* 17.03.03 sasco - сверка платежей по наименованию получателя */

def input param h-aaa like aaa.aaa.
def output param dss1 as dec.

{d-2-u.i} /* Транслятор DOS - Unix */
{name-compare.i}

def shared var g-today as date.
def stream s-file.

def frame  a-show with row 4 centered overlay no-labels title '[ Ждите ]'.

def var v-file as char no-undo init ''.
def var cl     as char no-undo.
def var ds     as dec  decimals 2 no-undo format '>>>,>>>,>>>,>>9.99'.
def var dss    as dec  decimals 2 no-undo format '>>>,>>>,>>>,>>9.99'.
def var c1     as char no-undo format 'x(08)'.
def var c2     as char no-undo format 'x(25)'.
def var c3     as char no-undo format 'x(09)'.
def var c4     as char no-undo format 'x(09)'.
def var c5     as char no-undo format 'x(09)'.
def var c6     as char no-undo format 'x(09)'.
def var c7     as char no-undo format 'x(08)'.
def var c8     as char no-undo format 'x(25)'.
def var c9     as char no-undo format 'x(09)'.
def var c10    as char no-undo format 'x(09)'.
def var c11    as char no-undo format 'x(09)'.
def var c12    as char no-undo format 'x(09)'.
def var c13    as char no-undo format 'x(09)'.
def var c14    as char no-undo format 'x(1)'.
def var c15    as char no-undo.
def var accnt  as integer no-undo format '999999999'.
def var faccnt as integer no-undo format '999999999'.
def var i      as integer no-undo.
def var ourbank as char no-undo format 'x(09)'.

def var v-bad-name as logical no-undo.
def var v-bad-pref as logical no-undo.
def var v-s1 as char NO-UNDO.
def var v-s2 as char NO-UNDO.
def var gv-s1 as char NO-UNDO init "".
def var tmpi as int NO-UNDO.
def var rnnind as int NO-UNDO.
def var tmpd as decimal NO-UNDO.


find sysc where sysc.sysc = "CLECOD" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    display " This isn't record CLECOD in sysc file !!".
    pause.
    return.
end.
ourbank = trim(sysc.chval).

find first sysc where sysc.sysc = "150fle" no-lock no-error.
if avail sysc then v-file = trim(sysc.chval). 
              else v-file = "/data/import/150.txt".

    display "Идет обработка данных..." skip with frame a-show.

    i = 0. dss = 0.
    input stream s-file from value( v-file ) no-echo.
    repeat:
    
       import stream s-file unformatted cl.
       cl  = d-2-u(  cl ).
       c1  = substr( cl, 01, 08 ). /* Дата       */
       c2  = substr( cl, 10, 25 ). /* Референс   */
       c3  = substr( cl, 36, 09 ). /* Банк отпр. */
       c4  = substr( cl, 46, 09 ). /* Счет отпр. */
       c5  = substr( cl, 56, 09 ). /* Банк получ */
       c6  = substr( cl, 66, 09 ). /* Счет получ */
       c7  = substr( cl, 76, 16 ). /* Сумма      */
       c8  = substr( cl, 93, 08 ). /* Плат.сис.  */
       c9  = substr( cl,102, 06 ). /* Дата вал.пл*/
       c10 = substr( cl,109, 12 ). /* Рнн отпр.  */
       c11 = substr( cl,122, 12 ). /* Рнн получ. */
       c12 = substr( cl,135, 80 ). /* Отправитель*/
       c13 = substr( cl,216, 80 ). /* Получатель */
       c14 = substr( cl,297, 01 ). /* Final ? 0/1*/
       c15 = substr( cl,299, length(cl) - 298 ). /* Назначение */

       faccnt = integer( c6 ).

       /* 11.05.2004 nadejda - условие на платежи ТОЛЬКО сегодняшней даты опердня */
       if int(h-aaa) = faccnt and c5 = ourbank and date (c1) = g-today then do:
          if (c8 = 'SCLEAR00' and c14 = "1")  or c8 = 'SGROSS00' then do:
          ds = dec( trim(c7) ).  /* Сумма */

          /*--- sasco: проверка наименований ----*/
          release cif.
          v-bad-name = no.
          v-bad-pref = no.
          find aaa where aaa.aaa = c6 no-lock no-error.
          if avail aaa then find cif where cif.cif = aaa.cif no-lock no-error.
          if avail cif then do:

    v-s1 = c13.
    v-s2 = c11.

    {trim-rnn.i}

             if not GCompare (cif.prefix + " " + cif.name  , v-s1, cif.cif) then
             if not GCompare (cif.prefix + " " + cif.sname , v-s1, cif.cif) then 
             if not GCompare (cif.name   + " " + cif.prefix, v-s1, cif.cif) then
             if not GCompare (cif.sname  + " " + cif.prefix, v-s1, cif.cif) then v-bad-name = yes.

             /* если не прошла сверка по имени - проверим форму собств. */
             if v-bad-name then 
                /* сверяем форму собств. в начале названия */
                if CAPS (cif.prefix) <> SUBSTR (TRIM(CAPS(v-s1)), 1, LENGTH (cif.prefix)) then 
                do:
                   /* если не прошло - то в конце названия */
                   if LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix) + 1 > 0 and 
                      CAPS (cif.prefix) <> SUBSTR (TRIM(CAPS(v-s1)), LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix) + 1) 
                           then v-bad-pref = yes.
                   else 
                   if LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix) > 0 
                   then if SUBSTR (TRIM(CAPS(v-s1)), LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix), 1) <> " " 
                                 then v-bad-pref = yes.
                end.

          end.
          /*-------------------------------------*/

          if v-bad-name or v-bad-pref then message "Внимание!~nПлатеж на сумму " + TRIM (STRING (ds, "z,zzz,zzz,zzz,zz9.99")) + 
                                                   "~nне прошел сверку по наименованию получателя" +
                                                   "~nсумма не доступна для предоставления овердрафта" 
                                                   view-as alert-box title "Прогнозные платежи для " + h-aaa.
          else dss1 = dss1 + ds.

          end. 
       end.
    end.
 pause 0.

    hide frame a-show.  
 pause 0.

    input stream s-file close.


/*  21.04.2005 kanat - проверка на очереди DIRIN - очереди входящих платежей для ПКО */
          for each que where que.pid = "DIRIN" no-lock.
          find first remtrz where remtrz.remtrz  = que.rem no-lock no-error.
          if avail remtrz then do:

	 	find first aaa where aaa.aaa = replace(trim(remtrz.ba),"/","") no-lock no-error. /* remtrz.racc иногда бывает пустой ... */
	 	if avail aaa and aaa.aaa = string(integer(h-aaa), "999999999") then do:

          v-bad-name = no.
          v-bad-pref = no.
          find cif where cif.cif = aaa.cif no-lock no-error.
          if avail cif then do:

    if trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]) <> "" then do:  
    v-s1 = entry(1, trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]),"/"). 
    v-s2 = entry(3, trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]),"/"). 
    end.

    {trim-rnn.i}

             if not GCompare (cif.prefix + " " + cif.name  , v-s1, cif.cif) then
             if not GCompare (cif.prefix + " " + cif.sname , v-s1, cif.cif) then 
             if not GCompare (cif.name   + " " + cif.prefix, v-s1, cif.cif) then
             if not GCompare (cif.sname  + " " + cif.prefix, v-s1, cif.cif) then v-bad-name = yes.

             /* если не прошла сверка по имени - проверим форму собств. */
             if v-bad-name then 
                /* сверяем форму собств. в начале названия */
                if CAPS (cif.prefix) <> SUBSTR (TRIM(CAPS(v-s1)), 1, LENGTH (cif.prefix)) then 
                do:
                   /* если не прошло - то в конце названия */
                   if LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix) + 1 > 0 and 
                      CAPS (cif.prefix) <> SUBSTR (TRIM(CAPS(v-s1)), LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix) + 1) 
                           then v-bad-pref = yes.
                   else 
                   if LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix) > 0 
                   then if SUBSTR (TRIM(CAPS(v-s1)), LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix), 1) <> " " 
                                 then v-bad-pref = yes.
                end.
                end.

          if v-bad-name or v-bad-pref then message "Внимание!~nПлатеж на сумму " + TRIM (STRING (remtrz.amt, "z,zzz,zzz,zzz,zz9.99")) + 
                                                   "~nне прошел сверку по наименованию получателя" +
                                                   "~nсумма не доступна для предоставления овердрафта" 
                                                   view-as alert-box title "Прогнозные платежи для " + h-aaa.
          else dss1 = dss1 + remtrz.amt.
	 	end.
          end. 
          end.
