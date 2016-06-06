/* craccclr.p
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

{global.i}
{lgps.i }


def shared var s-remtrz like remtrz.remtrz .
def shared frame remtrz.
def buffer  tgl for gl.
def var acode like crc.code.
def var bcode like crc.code.
def var yn as log initial false format "Да/Нет".
def var ok as log format "Да/Нет".

{ps-prmt.i}

Message " Вы уверены ? " update yn .
     do  transaction:
find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive no-error.

/*
 if not (remtrz.jh1 eq 0 or remtrz.jh1 eq ?)   then do:
   Message " 1 проводка уже существует !!! " . pause.
   return.
 end.  
*/

{rmz.f}


if yn then do  :
find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock no-error.

if avail remtrz then do :
/*  remtrz.rbank = "". 
  remtrz.rcbank = "" . */
  remtrz.cracc = "" . 
  remtrz.crgl = 0.
  remtrz.racc = "". 
  remtrz.rsub = "".     
find first que  where que.remtrz = s-remtrz exclusive-lock no-error.
 if avail que then do:
  que.dp = today.
  que.tp = time.
    v-text  = remtrz.remtrz + 
    ' ПОЛЯ : К.Сч. КСГК Сч.П  П.п. очищены, ТИП  = '  + que.ptype .
     run lgps. 
  release que.
 end. 
 disp remtrz.rbank remtrz.rcbank remtrz.cracc remtrz.crgl remtrz.racc
 remtrz.rsub remtrz.ptype with frame remtrz.
   release remtrz.
end .
END.
   end. /*transaction */
