/* r-arptrx.p
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

/* r-gltrx.p */

{mainhead.i ARPTRX}  /* REPORT A/R A/P TRANSACTION */

define var fdt as date label "С ДАТЫ".
define var tdt as date label "ПО ДАТУ".
define var vgl like gl.gl.
define var vtitle2 as char form "x(132)".
def var vwho like jl.who.

def var vcif like cif.cif.

fdt = g-today.
tdt = g-today.

{image1.i rpt.img}
if g-batch eq false
  then do:
    update
      fdt tdt
      with row 8 centered no-box side-label frame opt.
  end.
{image2.i}

{report1.i 59}
vtitle = "REPORT A/R A/P TRANSACTION :" + string(fdt) + "-" + string(tdt).
vtitle2 =
"Control#           Debit          Credit            REMARKS[1]
                                              UPDT BY".

form jl.jh
     jl.dam  format "z,zzz,zzz,zz9.99CR"
     jl.cam  format "z,zzz,zzz,zz9.99CR"
     jl.acc jl.rem[1] format "x(45)" jh.cif jl.who
  with no-label width 132 down frame detail.

for each jl where jl.jdt ge fdt
             and  jl.jdt le tdt
   ,each gl where gl.gl eq jl.gl and gl.subled eq "ARP"
   ,jh where jh.jh eq jl.jh
            break by jl.gl by jl.jdt by jl.jh by jl.ln:
  {report2.i 132 "vtitle2 fill(""="",132) format ""x(132)"" "}
  if first-of(jl.gl)
    then do:
      if not first(jl.gl) then page.
      display gl.gl gl.des
        /*
        gl.dam[3] - gl.cam[3] format "z,zzz,zzz,zz9.99CR" label "START BALANCE"
        */
        gl.pdam[1] - gl.pcam[1] format "z,zzz,zzz,zz9.99CR"
          label "START BALANCE"
        when (fdt eq g-today and tdt eq g-today)
        with width 132 side-label frame gl.
     end.

  display jl.jh
          jl.dam
          jl.cam
          jl.acc jl.rem[1] jh.cif jl.who string(jh.tim,"HH:MM:SS")
          with frame detail.
  down 1 with frame detail.
  accumulate jl.dam (sub-total by jl.gl by jl.jdt)
             jl.cam (sub-total by jl.gl by jl.jdt).

  if last-of(jl.jdt)
    then do:
      underline jl.dam jl.cam with frame detail.
      down 1 with frame detail.
      display accum sub-total by jl.jdt jl.dam @ jl.dam
              format "z,zzz,zzz,zz9.99CR"
              accum sub-total by jl.jdt jl.cam @ jl.cam
              format "z,zzz,zzz,zz9.99CR"
              string(jl.jdt) @ jl.rem[1]
              with frame detail.
      down 2 with frame detail.
    end.
  if last-of(jl.gl)
    then do:
      if fdt ne tdt
        then do:
          underline jl.dam jl.cam with frame detail.
          down 1 with frame detail.
          display accum sub-total by jl.gl jl.dam @ jl.dam
                  format "z,zzz,zzz,zz9.99CR"
                  accum sub-total by jl.gl jl.cam @ jl.cam
                  format "z,zzz,zzz,zz9.99CR"
                  with frame detail.
        end.
        down 1 with frame detail.
      display gl.dam[1] - gl.cam[1] format "z,zzz,zzz,zz9.99CR"
              when (fdt eq g-today and tdt eq g-today)
           label "END BALANCE" with side-label frame ebal.
    end.
end.
hide frame rptbottom.
{report3.i}
{image3.i}
