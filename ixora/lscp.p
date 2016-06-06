/* lscp.p
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
def input-output parameter flag as inte.
def input-output parameter trecp as recid.
def input-output parameter clinp as inte.
def shared frame lonscp.
def shared var svopnamt as char format "x(21)".
def var vint like lnsch.stval.
def var fufu as inte.

{mainhead.i}

find lon where lon.lon = s-lon no-lock.
if lon.gua = "CL" then do:
/*
  find first lnsch where lnsch.lnn = s-lon and lnsch.flp = -1
                         and lnsch.fpn = 0 and lnsch.f0 = 0 no-lock no-error.
  if available lnsch then vopnamt = vopnamt + lnsch.paid.
  */
  /* vopnamt = lon.opnamt. */
end.

if flag = 14 then do:
{lscp-mont.i}
clinp = 0.
end.

flag = 0.
svopnamt = string(vopnamt, "z,zzz,zzz,zzz,zz9.99-"). 

upper:
repeat:

{jjbr.i
&start = "if fufu = 0 then do: fufu = 1. trec = trecp. clin = clinp. end." 
&head = "lnsch"
&headkey = "schn"
&where = "lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0 
          and lnsch.f0 > -1"
&index = "lnn"
&formname = "lonscp"
&framename = "lonscp"
&addcon = "false"
&start = " "
&display = "lnsch.schn lnsch.stdat lnsch.stval lnsch.comment"
&postdisplay = "view frame msgh."
&postadd = "lnsch.lnn = s-lon."
&postkey = "else if lastkey = 49 then do:
               flag = 31. leave outer.
            end.
            else if lastkey = 50 then do:
               flag = 11. leave outer.
            end.
            else if lastkey = 51 then do:
                update vopnamt label 'Сумма' with frame a1svl overlay 
                side-label.
                hide frame a1svl. 
            end.
            else if lastkey = 52 then do:
               flag = 14. leave outer.
            end.
            else if lastkey = 13 then do:
            {lscp13.i &where = "lnsch.lnn = s-lon and lnsch.f0 > -1
                            and lnsch.flp = 0 and lnsch.fpn = 0"}
            end."
&end = "hide frame msgh. leave upper."
}
end. /* upper */
clinp = clin.
trecp = trec.
/*-----------------------------------------------------------------------
  #3.
     1.izmai‡a -atЅ±irЁga kalend–ra formёЅana LO un CL (vopnamt)
------------------------------------------------------------------*/
