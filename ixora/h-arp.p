/* h-arp.p
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

/* h-arp.p
*/
define var vselect as cha format "x".
def var bal like arp.dam[1] label "BALANCE".

Message "Н)омер карточки  И)наименование П)римечание" update vselect.  

{global.i}
if vselect eq "Н" or vselect eq "н" or vselect eq "y"
then do :
{itemlist.i
       &form = "arp.arp arp.des arp.cif bal "
       &updvar = "def var varp like arp.arp.
                  {imesg.i 1828} update varp."
       &file = "arp"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &where = "arp.arp ge varp"
       &predisp = "find first gl where gl.gl = arp.gl no-lock no-error.
                   if avail gl then do :
                     if gl.type = ""a"" then bal = arp.dam[1] - arp.cam[1].
                     else if gl.type = ""l"" 
                     then bal = arp.cam[1] - arp.dam[1].
                   end."
       &flddisp = "arp.arp arp.des arp.cif bal "
       &chkey = "arp"
       &chtype = "string"
       &index  = "arp"
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." 
       &set = "N"
       }
end.
else if vselect eq "И" or vselect eq "и" or vselect eq "b"
then do :
{itemlist.i
      &form = "arp.arp arp.des arp.cif bal "
      &updvar = "def var darp like arp.des.
                Message ""Введите наименование "" update darp.
                darp = '*' + darp + '*' ."
      &file = "arp"
      &frame = "row 5 centered scroll 1 12 down overlay "
      &where = "caps(arp.des) matches  caps(darp)"
      &predisp = "find first gl where gl.gl = arp.gl no-lock no-error.
                  if avail gl then do :
                    if gl.type = ""a"" then bal = arp.dam[1] - arp.cam[1].
                    else if gl.type = ""l""
                     then bal = arp.cam[1] - arp.dam[1].
                  end."
      &flddisp = "arp.arp arp.des arp.cif bal "
      &chkey = "arp"
      &chtype = "string"
      &index  = "arp"
      &funadd = "if frame-value = "" "" then do:
                   {imesg.i 9205}.
                   pause 1.
                    next.
                 end." 
      &set = "I"
      }
end.
else if vselect eq "П" or vselect eq "п" or vselect eq "g"
then do:

{itemlist.i
      &form = "arp.arp arp.des arp.cif bal "
      &updvar = "def var parp like arp.rem.
                Message ""Введите примечание "" update parp.
                parp = '*' + parp + '*' ."
      &file = "arp"
      &frame = "row 5 centered scroll 1 12 down overlay "
      &where = "caps(arp.rem) matches  caps(parp)"
      &predisp = "find first gl where gl.gl = arp.gl no-lock no-error.
                  if avail gl then do :
                    if gl.type = ""a"" then bal = arp.dam[1] - arp.cam[1].
                    else if gl.type = ""l""
                     then bal = arp.cam[1] - arp.dam[1].
                  end."
      &flddisp = "arp.arp arp.des arp.cif bal "
      &chkey = "arp"
      &chtype = "string"
      &index  = "arp"
      &funadd = "if frame-value = "" "" then do:
                   {imesg.i 9205}.
                   pause 1.
                    next.
                 end." 
      &set = "P"
      }
end.
