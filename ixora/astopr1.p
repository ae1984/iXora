/* astopr1.p
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
            24/05/2013 Luiza - ТЗ 1842 закрепление ОС за сотрудником
            27/05/2013 Luiza - перекомпиляция
*/

def new global shared var vv-ast like ast.ast format "x(8)".
def shared var v-ast like ast.ast format "x(8)".
def new shared var s-jh like jh.jh.
def var v-astn like ast.name.
/*def new shared var v-dt1 as date .
def new shared var v-dt2 as date .
*/
def var flag as int.
define shared variable v-icost like ast.icost format "zzzzzz,zzz,zz9.99-".
define shared variable v-atl  like ast.icost format "zzzzzz,zzz,zz9.99-".
define shared variable v-nol  like ast.icost format "zzzzzz,zzz,zz9.99-".
define shared variable v-nach like ast.icost format "zzzzzz,zzz,zz9.99-" .
define shared variable v-fagn  like ast.name.
define shared variable v-addrn like ast.name.
define shared variable v-attnn like ast.name.
define shared variable v-ofc as char.
def var v-dam  as decim format "zzz,zzz,zz9.99-".
def var v-cam  as decim format "zzz,zzz,zz9.99-".
def shared var v-gl1d like gl.des.
def shared var v-gl3d like gl.des.
def shared var v-fil as char.
def shared var v-filn as char.
def shared var v-gl3 like trxlevgl.glr.
def shared var v-gl4 like trxlevgl.glr.
def shared var v-am like trxlevgl.glr.
def var v-gl like astjln.agl.
def var v-gl1 like astjln.agl.
def var s-recid as int.
def input parameter vib as char.
/* KOVAL */
define new shared variable f-cont  like fagn.cont.
define new shared variable f-ref   like fagn.ref.
/* KOVAL */


/* отличие no astopr  frame, vib, nav 2 storno */

{global.i }
{astjln.f}
{astp.f}
{astjln2.f}

form "<Enter>- Просмотр,печать   1- История     <F4> - Выход "
       with overlay column 15 row 21 no-box color messages frame msgp.

find ast where ast.ast = v-ast no-lock.

find first fagn where fagn.fag = ast.fag no-lock no-error.
 if available fagn then assign
   				v-fagn = fagn.naim
   				f-cont = fagn.cont /* KOVAL */
   				f-ref  = fagn.ref.

main:

repeat:
view frame msgp.
/* jjbr.i */
{jabrw.i
&head = "astjln"
&headkey = "aast"
&index = "astdt"
&where = "astjln.aast=v-ast and
         (if vib='1' then astjln.d[1] ne 0 or astjln.c[1] ne 0
                     else astjln.d[3] ne 0 or astjln.c[3] ne 0)"
&formname = "astjln2"
&framename = "astjln2"
&addcon = "false"
&deletecon ="false"
&start = " "
&highlight = "astjln.ajdt v-dam v-cam  astjln.apriz
              astjln.aqty  astjln.arem[1] astjln.atrx"
&predisplay=" if vib='1' then do: v-dam=astjln.d[1]. v-cam=astjln.c[1]. end.
                         else do: v-dam=astjln.d[3]. v-cam=astjln.c[3]. end.
                          "
&display = "astjln.ajdt v-dam v-cam  astjln.apriz
            astjln.aqty astjln.arem[1] astjln.atrx"
&postdisplay = " "
&postkey = "else if keyfunction(lastkey) = '1' then do  /*transaction*/ /* 49 */
            on endkey undo,next:
             find ast where ast.ast=astjln.aast no-lock no-error.
             v-atl=ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3].
             v-icost = ast.dam[1] - ast.cam[1].
             v-nol = ast.cam[3] - ast.dam[3].
             v-gl1 = astjln.agl.
             v-am =v-gl3.

    displ   v-gl1 astjln.agl ast.rdt  v-atl v-am v-icost v-nol
            ast.qty astjln.ajdt
            g-today
            astjln.awho astjln.c[1] astjln.d[1] astjln.d[3] astjln.c[3]
            astjln.d[4] astjln.c[4]
            astjln.aqty astjln.ajh astjln.arem[1] astjln.arem[2]
            astjln.korgl astjln.koracc astjln.kpriz astjln.atrx
            astjln.stdt astjln.stjh /*astjln.crline*/ v-gl3 v-gl4 v-am
            /*astjln.prdec[1]*/
            with frame astjln.
            hide frame astjln .
            view frame msgp.
      /*   next upper. */
        end.

        else if keyfunction(lastkey) = 'return' then
        do on endkey undo, leave:  /* Enter */
             s-jh=astjln.ajh. vv-ast=astjln.aast.
             s-recid=recid(astjln).
          find jh where jh.jh=s-jh no-lock  no-error.
          if available jh then do:
           find first jl where jl.jh=s-jh no-error.
            if available jl then do:
             run ast-jlvouR.   /* run asts-jls(s-jh,vv-ast).*/
            end.
          end.
           find ast where ast.ast = v-ast no-lock no-error.
           if not avail ast then return.
            v-atl = ast.dam[1] - ast.cam[1].
            v-nol = ast.icost - (ast.dam[1] - ast.cam[1]).
            v-nach = ast.amt[3] + ast.salv.
             display ast.ast ast.addr[2] ast.name ast.fag v-fagn ast.gl
             ast.rdt ast.noy ast.qty ast.ser ast.icost ast.amt[4]
             ast.salv v-atl v-nol v-nach ast.meth ast.ldd ast.noy ast.amt[1]
             ast.addr[1] v-addrn ast.attn v-attnn ast.mfc ast.rem
             ast.dam[1] ast.cam[1] ast.ydam[5]
             /*ast.cont*/ f-cont ast.ref f-ref ast.ddt[1] ast.crline ast.dam[5] ast.ddt[4] ast.amt[4] ast.cam[4]
             v-fil v-filn
              with frame astp.
         pause 0.
         find astjln where recid(astjln) = s-recid no-lock no-error.
         if not avail astjln then return.

         leave.
         end. "
&postadd = " "
&end = "hide frame msgp. leave main."
}
end.

/*
&postkey = "else if lastkey = 49 then do  /*transaction*/ /* 1 */
            on endkey undo,next upper:
             find ast where ast.ast=astjln.aast no-lock no-error.
             v-atl=ast.dam[1] - ast.cam[1].
    displ   astjln.agl ast.rdt  v-atl ast.qty astjln.ajdt g-today
            astjln.awho  astjln.apriz astjln.cam astjln.dam
            astjln.aqty astjln.ajh astjln.arem[1] astjln.arem[2]
            astjln.korgl astjln.koracc astjln.kpriz astjln.atrx
            astjln.stdt astjln.stjh astjln.icost astjln.crline
            astjln.prdec[1]
          with frame astjln.

    display ast.ast ast.addr[2] ast.name ast.fag v-fagn ast.gl
             ast.rdt ast.noy ast.qty ast.ser ast.icost ast.amt[4]
             ast.salv v-atl v-nol v-nach ast.meth ast.ldd ast.noy ast.amt[1]
             ast.addr[1] v-addrn ast.attn v-attnn ast.mfc ast.rem
             ast.dam[1] ast.cam[1] ast.ydam[5]
             f-cont f-ref /*ast.cont*/ ast.ref ast.ddt[1] ast.crline ast.dam[5] ast.ddt[4] ast.amt[4] ast.cam[4]
           with frame astp.
           pause 0.
           view frame msgp.
         next upper.
      end.

        else if lastkey = 13 then do on endkey undo, leave:
             s-jh=astjln.ajh. vv-ast=astjln.aast.

          find jh where jh.jh=s-jh no-lock  no-error.
          if available jh then do:
           find first jl where jl.jh=s-jh no-error.
            if available jl then do:
               run asts-jls(s-jh,vv-ast).
            end.
          end.
           find ast where ast.ast = v-ast no-lock no-error.
           if not avail ast then return.
            v-atl = ast.dam[1] - ast.cam[1].
            v-nol = ast.icost - (ast.dam[1] - ast.cam[1]).
            v-nach = ast.amt[3] + ast.salv.
             display ast.ast ast.addr[2] ast.name ast.fag v-fagn ast.gl
             ast.rdt ast.noy ast.qty ast.ser ast.icost ast.amt[4]
             ast.salv v-atl v-nol v-nach ast.meth ast.ldd ast.noy ast.amt[1]
             ast.addr[1] v-addrn ast.attn v-attnn ast.mfc ast.rem
             ast.dam[1] ast.cam[1] ast.ydam[5]
             f-cont f-ref /*ast.cont*/ ast.ref ast.ddt[1] ast.crline ast.dam[5] ast.ddt[4] ast.amt[4] ast.cam[4]
              with frame astp.
         pause 0.
         next upper.
        end."
*/
