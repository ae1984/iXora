/* name2sort.i
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
*/

/* name2sort.i 
   Функция кодирования строки для сортировки

   15.11.2002 nadejda создан
*/

function name2sort returns char (p-value as char).
  def var s as char.
  def var c as char.
  def var i as integer.
  def var n as integer.
  def var massname as char init "0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,А,Б,В,Г,Д,Е,Ж,З,И,Й,К,Л,М,Н,О,П,Р,С,Т,У,Ф,Х,Ц,Ч,Ш,Щ,Ъ,Ы,Ь,Э,Ю,Я,".
  def var massnode as char init "01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,". 
  def var v-maxlen as integer init 70.

  s = "". 
  do i = 1 to length(p-value):
    c = caps(substring(p-value, i, 1)). 
    n = lookup(c, massname).
    if n = 0 then s = s + c. else 
    s = s + entry(n, massnode). 
    if length(s) >= v-maxlen then leave.
  end.
  return s.
end.
