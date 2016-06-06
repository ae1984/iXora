/* chpsw0.p
 * MODULE
        Администрирование ПРАГМЫ
 * DESCRIPTION
        Собственно процедура смены пользователем своего пароля
 * RUN
        
 * CALLER
        chpsw.p, chpswmenu.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9-1-8, вход в ПРАГМУ
 * AUTHOR
        11.11.2003 nadejda  - выделено из chpsw.p
 * CHANGES
        09.12.2003 nadejda  - добавила прописывание даты смены пароля
        12.02.2004 nadejda  - добавлен ввод подтверждения пароля
                              синхронизация пароля на базе статистики
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/


def input parameter p-ask as logical.
def output parameter p-newpswd as logical init no.

define var x like _password view-as fill-in no-undo.
define var xx like _password view-as fill-in no-undo.

def var v-letter as char init "abcdefghijklmnopqrstuvwxyz".
def var v-digit  as char init "0123456789".
def var v-rusletter as char init "абвгдеёжзийклмнопрстуфхцчшщъыьэюя".
def var v-ans as logical.
def var v-err as integer.
def var v-oldpswd as char.
def var v-user as char.
def var i as integer.
def var v-txt as char.

def var v-msgs as char extent 5 init
[" Введите пароль!",
 " Длина пароля должна быть не меньше 8 символов!",
 " Пароль должен содержать цифры и латинские буквы!",
 " Пароль не должен содержать русских букв!",
 " Новый пароль должен отличаться от старого!"
].



function chk-psw returns logical (input p-value as char).
  def var i as integer.
  def var l as logical.

  if p-value = "" then do:
    v-err = 1.
    return false.
  end.

  if length(p-value) < 8 then do:
    v-err = 2.
    return false.
  end.

  if encode(p-value) = v-oldpswd then do:
    v-err = 5.
    return false.
  end.

  l = false.
  do i = 1 to length(p-value):
    l = (index(v-letter, lc(substr(p-value, i, 1))) > 0).
    if l then leave.
  end.
  if not l then do:
    v-err = 3.
    return false.
  end.

  l = false.
  do i = 1 to length(p-value):
    l = (index(v-digit, lc(substr(p-value, i, 1))) > 0).
    if l then leave.
  end.
  if not l then do:
    v-err = 3.
    return false.
  end.

  l = false.
  do i = 1 to length(p-value):
    l = (index(v-rusletter, lc(substr(p-value, i, 1))) > 0).
    if l then leave.
  end.
  if l then do:
    v-err = 4.
    return false.
  end.

  return true.
end.

define frame frame1 
  skip(1)
  x  label " Введите новый пароль" blank
    help " Задайте пароль из цифр и латинских букв, не менее 8 символов"
    validate (chk-psw(x), v-msgs[v-err])
  skip
  xx label "     повторите пароль" blank
    help " Введите снова ваш новый пароль"
  "  "  skip(1)
  with side-labels overlay title " ИЗМЕНЕНИЕ ПАРОЛЯ ДЛЯ " + v-user centered row 5.

p-newpswd = no.

v-user = userid("bank").

find _user where _user._userid = v-user no-lock no-error.
v-oldpswd = _user._password.

i = 1.
repeat on endkey undo, return:
  x = "".
  xx = "".

  update x with frame frame1.
  update xx with frame frame1.

  hide message no-pause.
  if x = xx or i = 3 then leave.

  message " Пароль не подтвержден! Повторите ввод!".
  i = i + 1.
end.

if x = "" or xx = "" or (x <> xx) then return.

if p-ask then do:
  v-ans = no.
  message skip " Подтверждаете изменение пароля для пользователя" v-user "?" 
          skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-ans.

  if not v-ans then return.
end.


do transaction on error undo, return:
/* lookup the _user record based on the userid of user logged in */
  find _user where _user._userid = v-user exclusive-lock.
/* must use the encode function hereto ensure password encryption */
  assign _user._password = encode(x).
  release _user.

  find ofc where ofc.ofc = v-user exclusive-lock no-error.
  ofc.visadt = today.

  release ofc.
end.

/* если есть право на коннект к базе stat - поменять пароль там тоже */
find ofc where ofc.ofc = v-user no-lock no-error.
if index(ofc.expr[5], "s") > 0 then do:
  v-ans = no.
  if connected ("stat") then do:
    run chpsw0stat (v-user, x, output v-ans).
  end.
  else do:
    {comm-txb.i}
    v-txt = comm-txb().
    find txb where txb.logname = "stat" and txb.bank = v-txt no-lock no-error.
    if avail txb then do:
      connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld stat -U " + txb.login + " -P " + txb.password). 
      run chpsw0stat (v-user, x, output v-ans).
      if connected ("stat") then disconnect "stat".
    end.
  end.
  if v-ans then v-txt = "для базы банка и статистики ".
end.



/* вообще надо еще приконнектиться на ВСЕ базы и везде поменять пароль :-((( */

hide frame frame1 no-pause.

message skip " Пароль " + v-txt + "был успешно изменен." 
        skip(1) view-as alert-box title "".

p-newpswd = yes.

