/* valoda.p
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


def var source as cha format "x(50)".
def var v-lang like msg.lang .
def shared var g-lang as cha format "x(2)".
def var prpath as cha.
def var vusr as cha.
   prpath = propath.
def var i as int.
def var l as int.
def var vold as cha.
def var nnn as cha.

def var menu  as cha format "x(20)" extent 3.

menu[1] = " RS - latvian ".
menu[2] = " RR - russian ".
menu[3] = " US - english ".

form menu[1] skip
     menu[2] skip
     menu[3] with no-label centered row 1 frame menu.
/*
vold = "RS/".
i = index(substr(prpath,1),vold).
if i = 0 then do:
vold = "US/".
i = index(substr(prpath,1),vold).
 if i = 0 then do:
  vold = "RR/".
  i = index(substr(prpath,1),vold).
/*  if i = 0 then do:
   display " Propath and g-lang not matches ".
   leave.
  end.
*/
 end.
end.

g-lang = substr(vold,1,2).
*/
display menu with with frame menu.
choose field menu with frame menu.

v-lang = substr(menu[frame-index],2,2).
/*if v-lang = g-lang then leave.
prpath = propath.

do transaction:
  vold = caps(g-lang) + "/".
  nnn = caps(v-lang) + "/".
  g-lang = v-lang.
 l = 1.
 repeat:
  i = index(substr(prpath,1),vold).
  if i = 0 then leave.
  overlay(prpath,i) = nnn.
  end.
 propath = prpath.
end.
*/
g-lang = v-lang.
