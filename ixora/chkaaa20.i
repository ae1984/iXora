/* chkaaa20.i
 * MODULE

 * DESCRIPTION
        Функции для формирования и проверки контрольной суммы для 20-тизначных счетов
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
        08/02/2010 galina
 * BASES
        BANK
 * CHANGES
        09/02/2010 galina - Мадияр поравил функцию, чтобы работала быстрее
*/


def var v-leter as char init "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z".

/*деление по модулю 97*/
function modulo_97 returns integer (input p-in as decimal).
 def var j as deci no-undo.
 def var s as char no-undo.
 j = p-in.
 repeat:
    s = ''.
    repeat:
        if deci(s + '97') < j then s = s + '97'.
        else leave.
    end.
    j = j - deci(s).
    if j <= 979797979797979797 then leave.
 end.
 return j modulo 97.
end.

/*замена букв цифрами*/
function get_figure returns char (input p-string as char).
  def var v-figure as char init "10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35".
  def var v-res as char.
  def var f as char.
  def var i as integer.
  i = 0.
  do i = 1 to length(p-string):
    f = "".
    if lookup(substr(p-string,i,1),v-leter) > 0 then f = entry(lookup(substr(p-string,i,1),v-leter),v-figure).
    else f = substr(p-string,i,1).
    v-res = v-res + f.
  end.
  return v-res.
end.

/*Проверка контрольной суммы для 20-тизначных счетов*/
function chkaaa20 returns logical (input p-aaa20 as char).
 def var v-aaa as char.
 def var v-chk as logi.
 v-chk = true.
 v-aaa = get_figure(substr(p-aaa20,5)) + get_figure("KZ") + "00".
 if deci(substr(p-aaa20,3,2)) <> (98 - modulo_97(deci(v-aaa))) then v-chk = false.
 return v-chk.
end.

