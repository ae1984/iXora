/* r-trial1.p
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
 * BASES
     BANK 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

    
{deftrial1.f}

find sysc where sysc.sysc = "GLPNT" no-lock no-error.
tt = sysc.chval .
repeat :
 create gll .
 gll.gllist = substr(tt,1,index(tt,",") - 1 ).
 tt = substr(tt,index(tt,",") + 1,length(sysc.chval)).
 if tt = "" then leave .
end.

vasof = g-today.
{image1.i rpt.img}
if g-batch eq false then
  update vasof with centered row 7 no-box frame opt.

vpost = false.
if g-batch eq false and vasof = g-today
 then do:
  bell.
  {mesg.i 0906} update vpost.
 end.


{image2.i}

if vpost eq true then run rbpost.

{report1.i 59}

/*************************/

for each jl where jl.jdt = vasof no-lock use-index jdt :
    find first gll where gll.gllist = string(jl.gl) no-lock no-error.

    if available gll then do :

/*        find last ofchis where ofchis.ofc = jl.who and ofchis.regdt <= vasof
              no-lock no-error.
        if available ofchis then v-point =  ofchis.point .
*/

        v-point = jl.point.

        find last point where point.point = v-point no-lock no-error.
        if available point then n-point =  point.addr[1].

/*        find ofc where ofc.ofc = jl.who no-lock no-error.
        if available ofc then v-point =  ofc.regno / 1000 - 0.5 .
*/

        v-point = jl.point.

        find first tbal where tbal.point = v-point and tbal.crc = jl.crc
         and tbal.gl = jl.gl no-error.
        if available tbal then do :
            tbal.dam = tbal.dam + jl.dam.
            tbal.cam = tbal.cam + jl.cam.
        end.
        else do :
            create tbal.
            tbal.point = v-point.
            tbal.npoint = n-point.
            tbal.crc = jl.crc.
            tbal.gl = jl.gl.
            tbal.dam = jl.dam.
            tbal.cam = jl.cam.
        end.
    end.
end.
/************************/

for each jl where jl.jdt eq vasof no-lock break by jl.crc by jl.gl :


            if first-of(jl.crc) then do:
        find crc where crc.crc = jl.crc no-lock.
        page.
        vtitle = " ОБОРОТЫ И БАЛАНС ЗА: "
              + string(vasof)  + "    ВАЛЮТА  " + crc.des.


        titl = "  Г/К      НАИМЕНОВАНИЕ                         ВХ.ОСТАТОК           "
         + "   ДЕБЕТ                КРЕДИТ              ИСХ.ОСТАТОК ".


    end.
    {report2.i 132 "titl"}

    if jl.dam gt 0 and jl.cam = 0 then dcnt = dcnt + 1.
    else if jl.dam = 0 and jl.cam gt 0 then ccnt = ccnt + 1.
    else do: dcnt = dcnt + 1. ccnt = ccnt + 1. end.
    accumulate jl.dam (total by jl.gl).
    accumulate jl.cam (total by jl.gl).
    if last-of(jl.gl) then do:
        dr = accum total by jl.gl jl.dam.
        cr = accum total by jl.gl jl.cam.
        find gl where gl.gl = jl.gl no-lock .
        find last cls where cls.whn < vasof no-lock no-error.
        if available cls then do:
            find last glday where glday.gdt <= cls.whn and glday.gl = jl.gl and
            glday.crc = jl.crc no-lock no-error.
            if available glday then vglbal = glday.dam - glday.cam.
            else vglbal = 0.
        end.
        else do:
            find glbal where glbal.gl eq gl.gl and glbal.crc eq jl.crc no-lock.
            vglbal = glbal.dam - glbal.cam.
        end.
        vsubbal = vglbal + dr - cr.
        if gl.type eq "L" or gl.type eq "O" or gl.type eq "R" then do:
            vglbal = - vglbal.
            vsubbal = - vsubbal.
        end.

	  display jl.gl gl.des format "x(30)"
		  vglbal
		  dr ( total by jl.crc )
		  cr (total by jl.crc )
		  vsubbal with no-box no-label width 132 .

       /******************************/

        for each tbal where tbal.gl = jl.gl and tbal.crc = jl.crc
        break by tbal.point :

            find gl where gl.gl = tbal.gl no-lock .
            find last cls where cls.whn < vasof no-lock no-error.
            if available cls then do:
                for each pglbal where pglbal.gl eq tbal.gl and
                pglbal.crc = tbal.crc and pglbal.point = tbal.point no-lock:
                    find last pglday where pglday.gl eq pglbal.gl
                    and pglday.crc eq pglbal.crc and
                    pglday.gdt le cls.whn and pglday.point = pglbal.point
                    and pglday.depart = pglbal.depart no-lock no-error.
                    if avail pglday then   
                       pvglbal = pvglbal + pglday.dam - pglday.cam.
                end.   /*pglbal*/
            end.
            else do:
                for each pglbal where pglbal.point = tbal.point
                and pglbal.gl eq tbal.gl and pglbal.crc eq tbal.crc no-lock:
                    pvglbal = pvglbal + pglbal.dam - pglbal.cam.
                end.
            end.
            pvsubbal = pvglbal + tbal.dam - tbal.cam.

            if gl.type eq "L" or gl.type eq "O" or gl.type eq "R" then do:
                pvglbal = - pvglbal.
                pvsubbal = - pvsubbal.
            end.

            display "ГРУППА" tbal.point tbal.npoint format "x(27)"
            pvglbal tbal.dam tbal.cam  pvsubbal with
            no-label no-box width 132.

                pvglbal = 0.
                pvsubbal = 0.
        end.
/********************************************/
    end.
end.
{report3.i}
{image3.i}
