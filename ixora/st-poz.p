/* st-poz.p
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
        TXB
 * AUTHOR
        14/04/06 nataly 
 * CHANGES
*/

{ stvar.i  }
{st-poz.i  }  /* New temp-table */

{global.i}
def var m-str  as char.

def var m-glpras   as int  extent 20.
def var m-glprasS  as char extent 20.
def var m-glsai    as int  extent 20.
def var m-glsaiS   as char extent 20.

def var m-usi    as char  extent 20.
def var m-us   as char extent 20.
def var m-eui    as char  extent 20.
def var m-eu   as char extent 20.
def var m-rui    as char  extent 20.
def var m-ru   as char extent 20.

def shared var v-crc as integer.
def shared var fdt as date .

def temp-table wglbal
    field crc like crc.crc 
    field gl  like glbal.gl  
    field bal like glbal.bal.
    
def temp-table dglbal
    field crc like crc.crc
    field gl  like glbal.gl
    field bal like glbal.bal.

def var str-glpras  as char.
def var str-glsai   as char.

def var str-us   as char.
def var str-eu   as char.
def var str-ru   as char.

def var v-strgl   as char.
def var str-glbal   as char.

def var v-buygl like gl.gl.
def var v-selgl like gl.gl.
def var v-gl like gl.gl.
def var v-bal as dec.

def var i as int.

/* ----------- svl 25.10.96 ------------- */
def var v-glpoz like gl.gl .
def var v-pozbal like glbal.bal.
find sysc "GLPOZ" no-lock  no-error.
if available sysc then v-glpoz = integer(entry(2,sysc.chval)).
else v-glpoz = 0.

 g-rptto = fdt. 

for each txb.crc where crc.crc = v-crc no-lock:
    create   st-poz.
    st-poz.crc = crc.crc.
    st-poz.crccode = crc.code.

    if g-today eq g-rptto then do :
        st-poz.crcrate = crc.rate[1].
        st-poz.crcnom  = crc.rate[9].
    end.
    else do :
        find last txb.crchis where crchis.crc eq crc.crc and crchis.rdt le g-rptto
        and crchis.sts ne 9 no-lock no-error.
        if available crchis then do :
            st-poz.crcrate = crchis.rate[1].
            st-poz.crcnom  = crchis.rate[9].
            st-poz.crccode = crchis.code.
        end.
        else do:
            st-poz.crcrate = crc.rate[1].
            st-poz.crcnom  = crc.rate[9].
        end.
    end.    
end.

m-str = "".
find txb.sysc "GLPRAS" no-lock no-error.
if available txb.sysc then do :
   m-str = trim(sysc.chval).
   str-glpras = m-str.
   do i=1 to 20 on error undo,next:
      m-glprasS[i] = substring(m-str,1,1).
      m-glpras[i]  = integer(substring(m-str,2,6)).
      m-str        = substring(m-str,8).
      if m-str     = "" then leave.
   end. 
end.
 
m-str = "".
find txb.sysc "GLSAIS" no-lock no-error.
if available sysc then do :
   m-str = trim(sysc.chval).
   str-glsai = m-str.
   do i=1 to 20 on error undo,next :
      m-glsaiS[i]  = substring(m-str,1,1).
      m-glsai[i]   = integer(substring(m-str,2,6)).
      m-str        = substring(m-str,8).
      if m-str     = "" then leave.              
   end.
end.

/*вытаскиваем счета aRP в долларах*/
m-str = "".
find txb.sysc "vpUSD" no-lock no-error.
if available sysc then do :
   m-str = trim(sysc.chval).
   str-us = m-str.
   do i=1 to 20 on error undo,next :
      m-usi[i]  = substring(m-str,1,1).
      m-us[i]  = substring(m-str,2,9).
      m-str    = substring(m-str,11).
      if m-str = "" then leave.              
   end.
end.

/*вытаскиваем счета aRP в евро*/
m-str = "".
find txb.sysc "vpEUR" no-lock no-error.
if available sysc then do :
   m-str = trim(sysc.chval).
   str-eu = m-str.
   do i=1 to 20 on error undo,next :
      m-eui[i]  = substring(m-str,1,1).
      m-eu[i]  = substring(m-str,2,9).
      m-str    = substring(m-str,11).
      if m-str = "" then leave.              
   end.
end.

/*вытаскиваем счета aRP в рублях*/
m-str = "".
find txb.sysc "vpRUB" no-lock no-error.
if available sysc then do :
   m-str = trim(sysc.chval).
   str-ru = m-str.
   do i=1 to 20 on error undo,next :
      m-rui[i]  = substring(m-str,1,1).
      m-ru[i]  = substring(m-str,2,9).
      m-str    = substring(m-str,11).
      if m-str = "" then leave.              
   end.
end.
  
str-glbal = str-glpras + str-glsai.

if g-rptto = g-today then do:
for each txb.jl where jl.jdt eq g-today no-lock :
    v-gl = jl.gl. 
    v-strgl = "*" + string(v-gl) + "*".  
    if   str-glpras  matches v-strgl or   str-glsai   matches v-strgl
    then do:      
        find txb.jh where jh.jh eq jl.jh no-lock.
        if txb.jh.post then next.
        find first dglbal where dglbal.gl eq v-gl and dglbal.crc eq
        jl.crc no-error.
        if not available dglbal then do :
            create dglbal.
            dglbal.gl  = v-gl.
            dglbal.crc = jl.crc.
        end.
        find txb.gl where gl.gl eq v-gl no-lock no-error.
        if available gl then do :
           if gl.type eq "A" or gl.type eq "E" then
              dglbal.bal = dglbal.bal + jl.dam - jl.cam.
           else
              dglbal.bal = dglbal.bal - jl.dam + jl.cam.
        end.
      end.
end.  /*jl*/
end.

for each txb.gl no-lock :
v-strgl = "*" + string(gl.gl) + "*".  
  if str-glbal matches v-strgl then do: 
    for each txb.crc where crc.crc = v-crc no-lock :
      find last glday  where glday.gl eq gl.gl and glday.crc eq crc.crc and
      glday.gdt le g-rptto no-lock no-error.          
        if available txb.glday then do :
            find first wglbal where wglbal.gl eq glday.gl
            and wglbal.crc eq glday.crc no-error.
            if not available wglbal then do :
                 create wglbal.
                wglbal.gl  = glday.gl.
                wglbal.crc = glday.crc.
                wglbal.bal = glday.bal.
            end.
            else do:
                 wglbal.bal = wglbal.bal + glday.bal.
            end.
          
            find first dglbal where dglbal.gl eq glday.gl and dglbal.crc
            eq glday.crc no-lock no-error.
            if available dglbal then
             wglbal.bal = wglbal.bal + dglbal.bal.
        end.
      end.
    end.
end.

for each st-poz:
  
  /* (5) arpusbil. prasibas */
  do i=1 to 20:  
     if m-glpras[i] = 0 then leave.
     find first wglbal where wglbal.gl eq m-glpras[i] and wglbal.crc
        eq st-poz.crc no-error.
      if available wglbal then do:
         if m-glprasS[i] eq "+" then
            st-poz.arppras = st-poz.arppras + wglbal.bal.
         else 
            st-poz.arppras = st-poz.arppras - wglbal.bal.
      end.
  end. /* do */
  
  /* (6) arpusbil. saist. */
  do i=1 to 20:  
     if m-glsai[i] = 0 then leave.
     find first wglbal where wglbal.gl eq m-glsai[i] and wglbal.crc
        eq st-poz.crc no-error.
      if available wglbal then do:
         if m-glsaiS[i] eq "+" then
            st-poz.arpsaist = st-poz.arpsaist + wglbal.bal.
         else 
            st-poz.arpsaist = st-poz.arpsaist - wglbal.bal.
      end.
  end. /* do */
  

 case st-poz.crc:
 when 2 then do i=1 to 20:   /* arpUS */
     if m-us[i] = "" then leave.
     if g-today eq g-rptto then 
     find txb.trxbal where trxbal.acc eq m-us[i] and trxbal.crc eq 1  
        and  trxbal.sub = 'arp' and trxbal.lev = 1 no-lock no-error.
     else find last txb.histrxbal where histrxbal.acc eq m-us[i] and histrxbal.crc eq 1  
        and histrxbal.dt <= fdt and histrxbal.sub = 'arp' and histrxbal.lev = 1 no-lock no-error.
      if available histrxbal or available trxbal then do:
          find txb.arp where arp.arp = m-us[i] no-lock no-error.
           if avail arp then find txb.gl where gl.gl = arp.gl no-lock no-error.
            if avail gl then do:
             if available histrxbal then do:
                   if gl.type = 'A' or gl.type = 'E' then v-bal = histrxbal.dam - histrxbal.cam.
                                         else   v-bal = histrxbal.cam - histrxbal.dam.    
             end.
             if available trxbal then do:
                   if gl.type = 'A' or gl.type = 'E' then v-bal = trxbal.dam - trxbal.cam.
                                         else   v-bal = trxbal.cam - trxbal.dam.    
             end.
            end.  /*gl*/
         if m-usi[i] eq "+" then
            st-poz.arpus = st-poz.arpus + v-bal.
         else 
            st-poz.arpus = st-poz.arpus - v-bal.
      end.
  end. /* do */
 when 3 then do i=1 to 20:    /* arpEUR */
     if m-eu[i] = "" then leave.
     if g-today eq g-rptto then 
     find txb.trxbal where trxbal.acc eq m-eu[i] and trxbal.crc eq 1  
        and  trxbal.sub = 'arp' and trxbal.lev = 1 no-lock no-error.
      else find last txb.histrxbal where histrxbal.acc eq m-eu[i] and histrxbal.crc eq 1  
        and histrxbal.dt <= fdt and histrxbal.sub = 'arp' and histrxbal.lev = 1 no-lock no-error.
      if available histrxbal or available trxbal then do:
          find txb.arp where arp.arp = m-eu[i] no-lock no-error.
           if avail arp then find txb.gl where gl.gl = arp.gl no-lock no-error.
            if avail gl then do:
             if available histrxbal then do:
              if gl.type = 'A' or gl.type = 'E' then v-bal = histrxbal.dam - histrxbal.cam.
                                             else   v-bal = histrxbal.cam - histrxbal.dam.    
             end.
             if available trxbal then do:
                   if gl.type = 'A' or gl.type = 'E' then v-bal = trxbal.dam - trxbal.cam.
                                         else   v-bal = trxbal.cam - trxbal.dam.    
             end.
            end. /*gl*/
         if m-eui[i] eq "+" then
            st-poz.arpeu = st-poz.arpeu + v-bal.
         else 
            st-poz.arpeu = st-poz.arpeu - v-bal.
      end.
  end. /* do */
   when 4 then do i=1 to 20:  /* arpRUR */
     if m-ru[i] = "" then leave.
     if g-today eq g-rptto then 
     find txb.trxbal where trxbal.acc eq m-ru[i] and trxbal.crc eq 1  
        and  trxbal.sub = 'arp' and trxbal.lev = 1 no-lock no-error.
     else  find last txb.histrxbal where histrxbal.acc eq m-ru[i] and histrxbal.crc eq st-poz.crc  
        and histrxbal.dt <= fdt and histrxbal.sub = 'arp' and histrxbal.lev = 1 no-lock no-error.
      if available histrxbal or available trxbal then do:
          find txb.arp where arp.arp = m-ru[i] no-lock no-error.
           if avail arp then find txb.gl where gl.gl = arp.gl no-lock no-error.
            if avail gl then do:
             if available histrxbal then do:
              if gl.type = 'A' or gl.type = 'E' then v-bal = histrxbal.dam - histrxbal.cam.
                                             else   v-bal = histrxbal.cam - histrxbal.dam.    
              end.
             if available trxbal then do:
                   if gl.type = 'A' or gl.type = 'E' then v-bal = trxbal.dam - trxbal.cam.
                                         else   v-bal = trxbal.cam - trxbal.dam.    
             end.
             end. /*gl*/
         if m-rui[i] eq "+" then
            st-poz.arpru = st-poz.arpru + v-bal.
         else 
            st-poz.arpru = st-poz.arpru - v-bal.
      end.
  end. /* do */
 end case.
  /*  message st-poz.crc st-poz.arpus st-poz.arpeu st-poz.arpru.*/
      
end. /* for st-poz */

