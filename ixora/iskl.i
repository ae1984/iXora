/* iskl.i
 * MODULE
        Ќ §ў ­ЁҐ ЏЮ®ёЮ ¬¬­®ё® Њ®¤Ц«О
 * DESCRIPTION
        Ќ §­ ГҐ­ЁҐ ЇЮ®ёЮ ¬¬К, ®ЇЁА ­ЁҐ ЇЮ®ФҐ¤ЦЮ Ё ДЦ­ЄФЁ©
 * RUN
        ‘Ї®А®Ў ўК§®ў  ЇЮ®ёЮ ¬¬К, ®ЇЁА ­ЁҐ Ї Ю ¬ҐБЮ®ў, ЇЮЁ¬ҐЮК ўК§®ў 
 * CALLER
        ‘ЇЁА®Є ЇЮ®ФҐ¤ЦЮ, ўК§Кў НИЁЕ МБ®Б Д ©«
 * SCRIPT
        ‘ЇЁА®Є АЄЮЁЇБ®ў, ўК§Кў НИЁЕ МБ®Б Д ©«
 * INHERIT
        ‘ЇЁА®Є ўК§Кў Ґ¬КЕ ЇЮ®ФҐ¤ЦЮ
 * MENU
        ЏҐЮҐГҐ­Л ЇЦ­ЄБ®ў ЊҐ­Н ЏЮ ё¬К 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        03/08/2006 nataly ¤®Ў ўЁ«  ДЦ­ЄФЁН Ц¤ «Ґ­ЁО 
*/

procedure del-excl.
  def input parameter p-aaa as char.
  def input parameter p-cif as char.
  def input parameter p-kod as char.

  find tarif2 where tarif2.str5 = p-kod and tarif2.stat = 'r' no-lock no-error.
  if avail tarif2 then do:
    
   find tarifex where tarifex.cif  = p-cif and tarifex.str5 = p-kod
                   and tarifex.stat = 'r' exclusive-lock no-error.
   if avail tarifex then do:
     for each tarifex2 where tarifex2.aaa = p-aaa and tarifex2.cif  = p-cif and tarifex2.str5 = p-kod
                   and tarifex2.stat = 'r' exclusive-lock .
           delete tarifex2.
     end.
   /* delete tarifex. */ /*­Ґ Ц¤ «ОҐ¬ Є«ЁҐ­Б , БЄ ¬®ёЦБ ЎКБЛ ЁАЄ«НГҐ­ЁО Ї® ¤ЮЦёЁ¬ Є®¬ЁААЁО¬ */
   end.

    release tarifex.
    release tarifex2.
  end.
end procedure.

procedure add-excl.
  def input parameter p-aaa as char.
  def input parameter p-cif as char.
  def input parameter p-kod as char.

  find tarif2 where tarif2.str5 = p-kod and tarif2.stat = 'r' no-lock no-error.
  if avail tarif2 then do:

    find tarifex where tarifex.cif  = p-cif and tarifex.str5 = p-kod
                   and tarifex.stat = 'r' exclusive-lock no-error.
    if not avail tarifex then do:
      create tarifex.
      assign tarifex.cif    = p-cif
             tarifex.kont   = tarif2.kont
             tarifex.pakalp = tarif2.pakalp
             tarifex.str5   = p-kod
             tarifex.crc    = 1
             tarifex.who    = g-ofc
             tarifex.whn    = g-today
             tarifex.stat   = 'r'
             tarifex.wtim   = time
             tarifex.ost  = tarif2.ost
             tarifex.proc = tarif2.proc
             tarifex.max1 = tarif2.max1
             tarifex.min1 = tarif2.min1.
      run tarifexhis_update.
    end.
    
    find tarifex2 where tarifex2.aaa = p-aaa
                   and tarifex2.cif  = p-cif and tarifex2.str5 = p-kod
                   and tarifex2.stat = 'r' exclusive-lock no-error.
    if not avail tarifex2 then do:
      create tarifex2.
      assign tarifex2.aaa    = p-aaa
             tarifex2.cif    = p-cif
             tarifex2.kont   = tarif2.kont
             tarifex2.pakalp = tarif2.pakalp
             tarifex2.str5   = p-kod
             tarifex2.crc    = 1
             tarifex2.who    = g-ofc
             tarifex2.whn    = g-today
             tarifex2.stat   = 'r'
             tarifex2.wtim   = time.
      run tarifex2his_update.
    end.
    assign tarifex2.ost  = 0
           tarifex2.proc = 0
           tarifex2.max1 = 0
           tarifex2.min1 = 0.
    
    release tarifex.
    release tarifex2.
  end.
end procedure.

procedure tarifexhis_update.
 create tarifexhis.
 buffer-copy tarifex to tarifexhis.
 end procedure.

procedure tarifex2his_update.
 create tarifex2his.
 buffer-copy tarifex2 to tarifex2his.
end procedure.
