/*
cif-kart
 * MODULE
        Операционка
 * DESCRIPTION
        Карточка с образцами подписей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Form-k
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        11/12/08 Levin Victor
 * BASES
 		BANK COMM
 * CHANGES
        21/01/2010 galina - определила переменную iin
        08/11/2010 madiyar - два адреса, каждый в своей строке
        04/07/2012 id00810 - заполнение v-iin
        06/06/2013 yerganat - tz1490, добавление входящего параметра
*/

{global.i}
def input parameter v-with-stamp as int.  /*0 - nothing, 1 - "С печатью", 2 - "Без печати"*/

def new shared var v-name as char.
def new shared var v-addr1 as char.
def new shared var v-addr2 as char.
def new shared var pass as char.
def new shared var v-work as char.
def new shared var v-rnn as char.
def new shared var v-tel as char.
def new shared var v-iik as char.
def new shared var my-log as char.
def new shared var v-ofile as char.
def new shared var s-yur as logical.
def new shared var yur as logical.
def new shared var s-yurhand as logical.
def new shared var v-pref as char.
def new shared var v-iin as char.

def var i as LOGICAL initial true.

def shared var s-cif like cif.cif.
yur = no.
s-yurhand = no.
v-ofile = 'kart.htm'.
    find first cif where cif.cif = s-cif no-lock no-error.
    IF AVAILABLE cif then
     do:
      v-name = replace(cif.name, '"', '&#34;').
      v-addr1 = trim(cif.addr[1]).
      v-addr2 = trim(cif.addr[2]).
      v-rnn = cif.jss.
      v-iin = cif.bin.
      pass = cif.pss.
      v-work = cif.ref[8].
      v-tel = string(cif.tel).
	  my-log = s-cif.
	  if cif.type = 'b' then do:
       if  v-with-stamp = 2  then /*Если без печати Для ИП выводить шаблон физ. лиц*/
	      s-yur = no.
       else
          s-yur = yes.
	   v-pref = cif.prefix.
	  end.
	  else do:
	   s-yur = no.
	  end.

      for each aaa where aaa.cif = s-cif no-lock break by aaa.aaa:
       find lgr where lgr.lgr = aaa.lgr no-lock.
        if lgr.led = 'ODA' then next.
         if aaa.sta <> "c" then do:
          if i = true then
           do:
            v-iik = aaa.aaa.
            i = false.
           end.
        else
         v-iik = v-iik + ', ' + aaa.aaa.
      end.
     end.
     end.
    run Form-k.