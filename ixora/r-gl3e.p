/* r-gl2e.p
 * MODULE
        Обороты по счетам ГК
 * DESCRIPTION
        Обороты по счетам ГК
 * RUN
        В цикле, с коннектом ко всем базам.
 * CALLER
        r-gl
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
         BANK COMM TXB
 * AUTHOR
        10/10/03 kim
 * CHANGES
        14/10/03 nataly  добавила ввод даты отчета + счета ГК
        21/10/03 nataly неправильно брался входящий остаток. Теперь реализовано через bglday
        08.01.2004 nadejda - не выдавать отчет для счетов без оборотов
        07/10/04 madiar - подправил поиск парной проводки (теперь по genln)
        08/10/04 madiar - поле genln при создании проводок без шаблона как правило не проставлялось, поэтому поиск парной проводки
                          при проставленном genln производится по этому полю, в противном случае - по старому
        14/03/05 sasco  - поиск корресп счета по b-jl.ln = vln
        13/04/05 suchkov - сделал эту p-шку на основе r-gl2. Добавил столбец "номер счета".
        26/04/05 suchkov - Добавил столбец "номер корреспондирующего счета".
        29.06.09 id00024 - Програмка клон на основе r-gl2e. Здесь все выводится в файл с html тэгами.
        12/07/2010 madiyar - if avail b-jl в put'e
*/

{r-gl.i "shared"}

def input parameter v-name as char.

def buffer bglday for txb.glday.
/*def var v-strText as char.*/
def buffer b-jl for txb.jl.
def var v-corracc as int format ">>>>>>".
def var v-outsum as dec format "->>>,>>>,>>>,>>>,>>9.99".
def var v-dat as date.
def var v-isdata as logical.
def var vln like txb.jl.ln.

find first txb.glday where txb.glday.gl = v-glacc and
          (txb.glday.gdt >= v-from and txb.glday.gdt <= v-to) and
          txb.glday.crc = v-valuta no-lock no-error.

if avail txb.glday then do:

    /* 08.01.2004 nadejda */
    v-isdata = false.
    do v-dat = v-from to v-to:
      find first txb.jl where txb.jl.gl = v-glacc and
                 txb.jl.jdt = v-dat and
                 txb.jl.crc = v-valuta use-index jdt no-lock no-error.
      if avail txb.jl then do:
        v-isdata = true.
        leave.
      end.
    end.

    if not v-isdata then return.
    /*******************/

    find txb.gl where txb.gl.gl = v-glacc no-lock no-error.

    put "<TABLE border=1>" skip.
    put "<TR>" skip.

    put "<td>" v-name format "x(25)" "<\/td>"   "<td><nobr> ОБОРОТЫ ПО СЧЕТУ " v-glacc " " skip gl.des format "x(40)" "<\/nobr><\/td>".
    put "<td> ЗА ПЕРИОД С " v-from " ПО " v-to "</td>" skip.

    put "<\/TR>" skip.
    put "<\/TABLE>" skip.
    /*21/10/03 nataly*/

    put "<br><br>" skip.

    find last bglday where bglday.gl = v-glacc and bglday.gdt < v-from and bglday.crc = v-valuta no-lock no-error.
    /*21/10/03 nataly*/

    put "<TABLE border=1>" skip.
    put "<TR>" skip.

    put "<td> Входящее сальдо </td>"  .

    if avail bglday then do:
      if txb.gl.type = "A" or  txb.gl.type = "E" then put "<td colspan=9> " bglday.bal " <\/td>" skip.
      else put "<td colspan=9> "  bglday.bal  " <\/td>"   skip.
    end.
    else do:
      if txb.gl.type = "A" or  txb.gl.type = "E" then put "<td colspan=9> " 0 format "z,zzz,zzz,zzz,zz9.99-"  " <\/td>" skip.
      else put "<td colspan=9> "  0 format "z,zzz,zzz,zzz,zz9.99-"  " <\/td>"  skip.
    end.

    put "<\/TR>" skip.
    put "<\/TABLE>" skip.
    /*put fill("-", 155) format "x(155)" skip.*/
    put "<TABLE border=1>" skip.

    do v-dat = v-from to v-to:
      for each txb.jl no-lock where txb.jl.gl = v-glacc and txb.jl.jdt = v-dat use-index jdt /* break by txb.jl.jh by txb.jl.crc*/:
        if txb.jl.crc <> v-valuta then next.
          v-dt = v-dt + txb.jl.dam.
          v-ct = v-ct + txb.jl.cam.
          /* проводка создавалась по шаблону */
          /*
          if txb.jl.genln <> 0 then do:
            find first b-jl where b-jl.jh = txb.jl.jh and b-jl.dam = txb.jl.cam and b-jl.cam = txb.jl.dam and b-jl.genln = txb.jl.genln no-lock no-error.
            if avail b-jl then do:
                v-corracc = b-jl.gl.
            end.
            else do:
                v-corracc = 0.
            end.
          end.
          else do:
          */
            /* проводка создавалась без шаблона, и при этом поле genln не было проставлено */
            vln = jl.ln.
            if vln mod 2 = 0 then vln = vln - 1.
                             else vln = vln + 1.
            find first b-jl where b-jl.jh = txb.jl.jh and b-jl.dam = txb.jl.cam and b-jl.cam = txb.jl.dam and /*(b-jl.ln + 1 = txb.jl.ln or b-jl.ln - 1 = txb.jl.ln)*/
                                  b-jl.ln = vln no-lock no-error.
            if avail b-jl then do:
                v-corracc = b-jl.gl.
            end.
            else do:
                v-corracc = 0.
            end.
          /* end. */
          put "<TR>" skip.
          put "<td>" txb.jl.jdt "<\/td><td>" txb.jl.jh "<\/td><td>" v-corracc "<\/td><td>" txb.jl.crc "<\/td><td>"
           txb.jl.dam "<\/td><td>" txb.jl.cam "<\/td><td>" txb.jl.rem[1] format "x(110)" txb.jl.rem[2] format "x(110)" txb.jl.rem[3] format "x(110)" "<\/td><td>" txb.jl.who "<\/td><td>" if avail b-jl then b-jl.acc else "" "<\/td>" skip .
          put "<\/TR>" skip.
      end.
    end. /*v-dat*/
    put "<\/TABLE>" skip.

    find last txb.glday where txb.glday.gl = v-glacc and txb.glday.gdt <= v-to and txb.glday.crc = v-valuta no-lock no-error.
    if not available glday then do:
        message "Внимание!!! Не найден остаток по Г/К на " v-to view-as alert-box.
        quit.
    end.

   /* put fill("-", 155) format "x(155)" skip*/
   put "<TABLE border=1>" skip.
   put "<TR>" skip.
   put "<td> Итого обороты <\/td><td>" v-dt "<\/td><td>" v-ct "<\/td>" skip.
    /*    fill("-", 155) format "x(155)" skip.*/
   put "<\/TR>" skip.
    /*if (txb.glday.gl > 0 and txb.glday.gl <= 199999) or (txb.glday.gl > )*/
    put "<TR>" skip.
    put "<td> Исходящее сальдо <\/td>".  /*  fill(" ", 11) format "x(11)" .*/
    if avail  bglday then do:
      if txb.gl.type = "A" or  txb.gl.type = "E" then put "<td>" bglday.bal + v-dt - v-ct format "z,zzz,zzz,zzz,zz9.99-" "<\/td>" skip.
      else put "<td>" bglday.bal + v-ct - v-dt format "z,zzz,zzz,zzz,zz9.99-" "<\/td>" skip.
    end.
    else do:
      if txb.gl.type = "A" or  txb.gl.type = "E" then put "<td>" 0 + v-dt - v-ct format "z,zzz,zzz,zzz,zz9.99-" "<\/td>" skip.
      else put "<td>" 0 + v-ct - v-dt format "z,zzz,zzz,zzz,zz9.99-" "<\/td>" skip.
    end.
    put "<\/TR>" skip.
    put "<\/TABLE>" skip.

    put "<br><br><br><br><br><br>" skip.
    v-ct = 0.
    v-dt = 0.
end.

