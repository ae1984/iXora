/* inw_I_ps.p
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
        21.02.2005 tsoy     - добавил время создания платежа.
*/

/*
 inw_I_ps.p
*/
/*
 for each remtrz where remtrz.sqn = "" . display remtrz.remtrz .
  end .
 for each remtrz where remtrz.sqn = "" . delete  remtrz.
   end .
*/
{mainhead.i INWRMZ}
def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.
def new shared var remtrz like remtrz.remtrz.
def var t-pay like remtrz.amt.
def new shared var v-option as cha .
{lgps.i "new"}
m_pid = "I" .
u_pid = "inw_I_ps" .
v-option = "rmzinw".

{main_ps.i
 &head = remtrz
 &headkey = remtrz
 &framename = remtrz
 &option = REMTRZ
 &formname = rmzi2
 &findcon = true
 &addcon = true
 &numprg = "n-remtrz"
 &keytype = string
 &nmbrcode = remtrz
 &subprg = s-remtrzi
 &clearframe = " "
 &viewframe = " "
 &postfind = "{posfnd.i}"
 &preadd = " "
 
 &prefind = "
   Display  ' <ПРОБЕЛ> - поиск платежа   <F3> - просмотр платежей для SWIFT'
     with overlay row 22 no-box . pause 0 .
 on any-key of remtrz.remtrz in frame remtrz 
 do:
  if keylabel(lastkey) = ' ' then do:
   s-remtrz = '' . 
   run u-search .
   remtrz.remtrz:screen-value in frame remtrz = s-remtrz .
  end. 
  if keyfunction(lastkey) = 'ENTER-MENUBAR' then do :
   s-remtrz = '' .   
   run remtrz-s .
  end .
  if keyfunction(lastkey) = 'HELP' then do :
   s-remtrz = '' .   
   run z-remtrz.
  end .
 end.
 "
 &postadd = " remtrz.rwho = g-ofc . 
  remtrz.source = m_pid . 
  remtrz.rtim = time.
  run rotlxzi . s-newrec = false .
 if keyfunction(lastkey) = ""end-error""
   then do :
   delete remtrz .
   return .
  end .  "
 &rls = " release remtrz. release que . "
 &end = " "
}  
