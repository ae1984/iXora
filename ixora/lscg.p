/* lscg.p
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
        04/05/06 marinav Увеличить размерность поля суммы
*/

/* LOAN PRINCIPAL VALUE RETURN SCHEDULE */
def shared var s-lon like lnsch.lnn.
def input parameter vduedt like lnscg.stdat.
def input parameter vregdt like lnscg.stdat.
def input parameter vopnamt like lnscg.stval.
def output parameter flag as inte.
def input-output parameter trecg as recid.
def input-output parameter cling as inte.
def shared frame lonscg.
def var fufu as inte.
def shared var svopnamt as char format "x(21)".

{mainhead.i}

find lon where lon.lon = s-lon no-lock.
if lon.gua = "CL" then do:

  find first lnsch where lnsch.lnn = s-lon and lnsch.flp = -1
                        and lnsch.fpn = 0 and lnsch.f0 = 0 no-lock no-error.
  if available lnsch then vopnamt = vopnamt + lnsch.paid.

end.

flag = 0.

svopnamt = string(vopnamt, "z,zzz,zzz,zzz,zz9.99-").

upper:
repeat:

{jjbr.i
&start = "if fufu = 0 then do: fufu = 1. trec = trecg. clin = cling. end." 
&head = "lnscg"
&headkey = "schn"
&where = "lnscg.lng = s-lon and lnscg.flp = 0 and lnscg.fpn = 0 
          and lnscg.f0 > -1"
&index = "lng"
&formname = "lonscg"
&framename = "lonscg"
&addcon = "false"
&start = " "
&display = "lnscg.schn lnscg.stdat lnscg.stval lnscg.paid"
&postdisplay = "view frame msgg."
&postadd = "lnscg.lng = s-lon."
&postkey = "else if lastkey = 49 then do:
               flag = 21. leave outer.
            end.
            else if lastkey = 50 then do:
               flag = 31. leave outer.
            end.
            else if lastkey = 51 then do:
                message ""Сумма к выдаче "" update vopnamt.
                svopnamt = string(vopnamt, ""z,zzz,zzz,zzz,zz9.99-"").
                hide frame lonscg.
                view frame lonscg.
            end.
            else if lastkey = 13 then do:
            {lscg13.i &where = "lnscg.lng = s-lon
                            and lnscg.flp = 0 and lnscg.fpn = 0
                                              and lnscg.f0 > -1"}
            end."
&end = "hide frame msgg. leave upper."
}
end. /* upper */
cling = clin.
trecg = trec.
