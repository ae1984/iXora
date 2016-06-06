/* aaa-trx.p
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
        09.09.2003 nadejda - добавлен индекс для оптимизации
        28.11.2003 nataly  - убрана проверка на счета GL, добавлена проверка на уровень
        28.04.2011 lyubov - добавила вывод КНП, отправителя, банка отправителя.
        12.09.2011 aigul - добавила КНП, КБЕ, КОД для платежей 2-2-3
        27.10.11 lyubov - исправила вывод КОД, КБЕ, КНП
        27.10.11 lyubov - убрала проверочний message
        05/12/2011 Luiza - подправила присвоение rem1 после вызова GetEKNP
        24.04.2012 Lyubov - дописала при выводе назначения платежа "colon 7 format "x(60)" "
        24.04.2012 Lyubov - убрала предыдущие изменения, добавила проверку "назначения" на символ ASCII 13 (перевод каретки),
                            если есть, то выводим без него
*/

/* checked */
/* aaa-trx.p  */
/*run qstmt. */
{global.i}

def shared var s-aaa like aaa.aaa.

def var vfdt as date label "С" format "99/99/9999".
def var vtdt as date label "По" format "99/99/9999".
def var vtrx as log  label "Тип Транз./Номер" format "Т/Н".
def var v-val as logical init false.
def var v-knp as char format 'x(25)'.
def var rem as char format 'x(98)'.
def var rem1 like rem.
def var i as integer.
def var j as integer.
def var k as integer.
def var otpr as char format 'x(40)'.
def var msg as char format 'x(20)' init 'Запись отсутствует.'.
def var len as int.
def var len1 as int.
def var rmz as char format 'x(10)'.
def var nazpl as char.
def var v-remtrz as char.
def var v-kod as char.
vfdt = date(month(g-today),1,year(g-today)).
vtdt = g-today.

def buffer b-jl for jl.

def var kod as char format "x(2)".
def var kbe as char format "x(2)".
def var knp as char format "x(3)".
def var kod1 as char format "x(2)".
def var kbe1 as char format "x(2)".
def var knp1 as char format "x(3)".

def var s1 as char.
def var n  as int.

update vfdt vtdt vtrx
  with side-label row 13 overlay centered frame opt.

find aaa where aaa.aaa eq s-aaa no-lock.
if vtrx
then for each aal where aal.aaa eq aaa.aaa
              and  aal.regdt ge vfdt
              and  aal.regdt le vtdt
             no-lock
             break by aal.aax by aal.aah by aal.regdt:
  find aab where aab.aaa eq aaa.aaa and aab.fdt eq aal.regdt no-lock.

  find aax where aax.lgr eq aaa.lgr and aax.ln eq aal.aax no-lock.
  if first-of(aal.aax)
  then do:
         display aal.aax label "TX"
                 aax.des label ''
               with row 9 centered overlay down frame trx1.
       end.
  display aal.aah   label 'Транз.' format 'zzzzzzz9'
          aal.regdt label 'Дата рег.'
          aal.amt * aax.drcr label 'Amount' form "z,zzz,zzz,zz9.99-"
          (sub-total by aal.aax)
          aal.fday  label 'Срок'
          aal.chk   label 'Чек'
  with frame trx1.
/*if last-of(aal.regdt) then display aab.bal. */
end.
else for each aal where aal.aaa eq aaa.aaa and  aal.regdt ge vfdt
and aal.regdt le vtdt no-lock by aal.aah:
  find aax where aax.lgr eq aaa.lgr and aax.ln eq aal.aax no-lock.
  display aal.aah      label 'Транз.' format 'zzzzzzz9'
          aal.regdt    label 'Дата рег.'
          aal.aax      label "TX"
          aax.des      label 'Операция'
          aal.amt * aax.drcr label "Сумма" format "z,zzz,zzz,zz9.99-"
          aal.fday     label 'Срок'
          aal.chk      label 'Чек'
          aal.sta      label 'Стс'
    with row 9 centered overlay down frame trx2.
end.


  /*28/11/03 nataly*/
  /*13/05/11 lyubov*/
for each jl where jl.acc = aaa.aaa and jl.jdt >= vfdt and jl.jdt <= vtdt /*and jl.gl = aaa.gl*/ no-lock use-index acc by jl.jh:
  if jl.lev <> 1 then next.
     find first jh where jh.jh = jl.jh no-lock no-error.
     if avail jh then do:
       find first remtrz where remtrz.remtrz = jh.ref no-lock no-error.
       if not avail remtrz then do: /* Luiza  */
            find first joudoc where joudoc.docnum = jh.ref no-lock no-error.
            if not avail joudoc then otpr = msg.
            else do: if trim(joudoc.info) <> "" then otpr = trim(joudoc.info) + ".". else otpr = msg. end.
       end. /*-------*/
       else do:
          if remtrz.tcrc <> 1 then v-val = true. else v-val = false.
          If v-val then otpr = trim(substr(remtrz.ord, 1,40 )).
          else do:
             otpr = trim( remtrz.ord ).
             i = r-index( remtrz.ord, '/RNN/' ).
          end.
       if i = 0 then otpr = remtrz.ord.
       else otpr = trim( substring( remtrz.ord, 1, i - 01 )).
     end.
                find first sub-cod where sub-cod.d-cod = 'eknp' and sub-cod.ccode = 'eknp' and sub-cod.sub = 'rmz' and sub-cod.acc = remtrz.remtrz no-lock no-error.
                if not avail sub-cod then do: /* Luiza*/
                    if avail joudoc then v-knp = 'КНП:'.
                    else v-knp = 'КНП:' + msg.
                end. /*----------*/
                else do: v-knp = 'КНП:' + substring( sub-cod.rcode, 07, 03 ).
                end.
     end.

if jl.dam <> 0 then do:

  len = LENGTH (jl.rem[1]).
  if len = 0 then do:
      rem = jl.rem[5].
      rem1 = ''.
  end.
  else do:
      rem = trim(substring(jl.rem[1], 1, 95)).
      rem1 = trim(substring(jl.rem[1], 96, 95)).

      j = r-index( rem, '/RNN/' ).
      if j = 0 then do:
          rem = trim(substring(rem, 1, 95)).
      end.
      else rem = trim( substring(rem, 1, j - 01 )).

      k = r-index( rem1, '/RNN/' ).
      if k = 0 then do:
      rem1 = trim(substring(rem1, 96, 95)).
      end.
      else rem1 = trim( substring(rem1, 1, k - 01 )).
  end.
end.

else do:
  len = LENGTH (jl.rem[1]).
  if len = 0 then do:
      rem = msg.
      rem1 = ''.
  end.
  else do:
      /*rem = trim(substring(jl.rem[1], 1, 85)).
      rem1 = trim(substring(jl.rem[1], 86, 85)).*/

      i = index( jl.rem[1], 'RMZ' ).
      if i = 0 then do:
          rem = trim(substring(jl.rem[1], 1, 55)).
          rem1 = trim(substring(jl.rem[1], 56, 80)).
          if avail joudoc then rmz = "". /* Luiza */
          else rmz = "RMZ:" + msg.
      end.
      else do:
          rmz = trim(substring(jl.rem[1], 1, 10 )).
          rem = trim( substring(jl.rem[1], 11, 70 )).
          rem1 = trim(substring(jl.rem[1], 81, 80)).
      end.

      j = r-index( rem, '/RNN/' ).
      if j <> 0 then
      rem = trim( substring(rem, 1, j - 01 )).

      k = r-index( rem1, '/RNN/' ).
      if k <> 0 then
      rem1 = trim( substring(rem1, 1, k - 01 )).

      len1 = length (rem1).
      if len1 = 0 then
      do:
          i = r-index ( rem, otpr ).
          if i <> 0 then
          rem = trim(substring(rem, 1, i - 01)).
          rem =  rmz + ' ' + v-knp + ' ' + rem + ' '.
          rem1 = "Отправитель: " + otpr.
      end.
      else
      do:
          i = r-index ( rem1, otpr ).
          if i <> 0 then
          rem1 = trim(substring(rem1, 1, i - 01)).
          rem =  rmz + ' ' + v-knp + ' ' + rem + ' '.
          rem1 = rem1 + ' ' + "Отправитель: " + otpr.
      end.

  end.
end.

find first jh where jl.jh = jh.jh no-lock no-error.
if avail jh then do:

if jh.sub <> "RMZ" then do:

    i = r-index( jl.rem[1], 'RMZ' ).
    if i <> 0 then do:
        v-remtrz = trim( substring(jl.rem[1], i, 10 )).
        if jl.ln = 1 or jl.ln = 2 then do:
            find last sub-cod where sub-cod.acc = v-remtrz and sub-cod.sub = 'rmz' and sub-cod.d-cod = 'eknp'and sub-cod.ccode = 'eknp' no-lock no-error.
            if avail sub-cod then
            rem1 = rem1 + ' ' + "КОД: " + substr(sub-cod.rcode,1,2) + " КБе: " + substr(sub-cod.rcode,4,2) + " КНП: " + substr(sub-cod.rcode,7,3).
        end.

        else do:
            if jl.acc <> "" then do:
                find first aaa where aaa.aaa = jl.acc no-lock no-error.
                if avail aaa then do:
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    if avail cif and cif.geo = "021" then v-kod = "1".
                    if avail cif and cif.geo <> "021" then v-kod = "2".
                    find first sub-cod where sub-cod.acc = aaa.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
                    if avail sub-cod then v-kod = v-kod + substr(sub-cod.ccode,1,2).
                end.
            end.

            else do:
                find first sub-cod where sub-cod.acc = v-remtrz and sub-cod.ccod = "eknp" no-lock no-error.
                if avail sub-cod then do:
                    v-kod = substr(sub-cod.rcode,1,2).
                end.
            end.
            rem1 = rem1 + ' ' + "КОД: " + v-kod + " КБе: 14 КНП: 840".
        end.
    end.

    else do:
    assign kod = "". kbe = "". knp = "". kod1 = "". kbe1 = "". knp1 = "".
        run GetEKNP(jl.jh, jl.ln, jl.dc, input-output kod, input-output kbe, input-output knp).
        find first b-jl where b-jl.jh = jl.jh and ((b-jl.dam <> 0 and b-jl.dam = jl.cam) or (b-jl.cam <> 0 and b-jl.cam = jl.dam)) no-lock no-error.
        if avail b-jl then do:
            run GetEKNP(b-jl.jh, b-jl.ln, b-jl.dc, input-output kod1, input-output kbe1, input-output knp1).
            if knp = "" then knp = knp1.
            if jl.dc = "C" then rem1 = rem1 + ' ' + "КОД: " + kod1 + " КБе: " + kbe + " КНП: " + knp.
            else rem1 = rem1 + ' ' + "КОД: " + kod + " КБе: " + kbe1 + " КНП: " + knp.
        end.
    end.
end.
/*end.*/
else do:
        v-remtrz = jh.ref.
        if jl.ln = 1 or jl.ln = 2 then do:
            find last sub-cod where sub-cod.acc = v-remtrz and sub-cod.sub = 'rmz' and sub-cod.d-cod = 'eknp'and sub-cod.ccode = 'eknp' no-lock no-error.
            if avail sub-cod then
            rem1 = rem1 + ' ' + "КОД: " + substr(sub-cod.rcode,1,2) + " КБе: " + substr(sub-cod.rcode,4,2) + " КНП: " + substr(sub-cod.rcode,7,3).
        end.

        else do:
            if jl.acc <> "" then do:
                find first aaa where aaa.aaa = jl.acc no-lock no-error.
                if avail aaa then do:
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    if avail cif and cif.geo = "021" then v-kod = "1".
                    if avail cif and cif.geo <> "021" then v-kod = "2".
                    find first sub-cod where sub-cod.acc = aaa.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
                    if avail sub-cod then v-kod = v-kod + substr(sub-cod.ccode,1,2).
                end.
            end.

            else do:
                find first sub-cod where sub-cod.acc = v-remtrz and sub-cod.ccod = "eknp" no-lock no-error.
                if avail sub-cod then do:
                    v-kod = substr(sub-cod.rcode,1,2).
                end.
            end.
            rem1 = rem1 + ' ' + "КОД: " + v-kod + " КБе: 14 КНП: 840".
        end.
    end.
end.

/*проверка на наличие в строке символа перевода каретки*/
     k = 0.
     n = length(rem).
     do i = 1 to n:
         k = k + 1.
         s1 = substr(rem,k,1).
         if asc(s1) = 13 then
         rem = substr(rem,1,k - 1) + substr(rem,k + 1).
     end.
/**/

     form jl.jdt label 'Дата'
          jl.dam label 'Дебет'
          jl.cam label 'Кредит'
          jl.jh  label 'Транзакция'
          jl.who label 'Исполн.'
          rem label 'Назначение платежа'
          rem1 label ''
          with frame jl row 1 centered overlay down width 100.

      display jl.jdt jl.dam jl.cam jl.jh jl.who rem rem1 with frame jl.
end.

/* 09.09.2003 nadejda
for each jl where jl.acc eq aaa.aaa and  jl.jdt ge vfdt and  jl.jdt le vtdt
no-lock, each gl of jl where gl.subled eq "cif" and gl.level eq 1 no-lock
by jl.jh:

  form jl.jdt label 'Дата'
       jl.dam label 'Дебет'
       jl.cam label 'Кредит'
       jl.jh  label 'Транзакция'
       jl.who label 'Исполн.' skip
       jl.rem[1] label "Описание"
       with row 9 centered overlay down frame jl.
  display jl.jdt jl.dam jl.cam jl.jh jl.who jl.rem[1] with frame jl.

end. */

