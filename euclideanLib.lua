local EuclideanLib={}

function EuclideanLib.GetNoteName(noteNumber)
      local NoteName = nil
      local subnote = noteNumber%12
      if subnote == 0 then
        NoteName="C"
      elseif subnote == 1 then
        NoteName = "C#"
      elseif subnote == 2 then
        NoteName = "D"
      elseif subnote == 3 then
        NoteName = "D#"
      elseif subnote == 4 then
        NoteName = "E"
      elseif subnote == 5 then
        NoteName = "F"
      elseif subnote == 6 then
        NoteName = "F#"
      elseif subnote == 7 then
        NoteName = "G"
      elseif subnote == 8 then
        NoteName = "G#"
      elseif subnote == 9 then
        NoteName = "A"
      elseif subnote == 10 then
        NoteName = "A#"
      elseif subnote == 11 then
        NoteName = "B"
      end
     local oct = math.floor(noteNumber/12)
     return NoteName .. " - " .. tostring(oct)
 end
 
EuclideanLib.noteColumn={
  insturment=64,
  drum_note=36,
  steps=64,
  hits=16,
  offset=0
}
 
function EuclideanLib.InitDataObj(columns)
  local EucList={}
  for i=1, columns, 1
  do
    EucList[i]=EuclideanLib.noteColumn;
    EucList[i].drumNote=64+i
  end
  return EucList
end

function EuclideanLib.RenderNotes(dcolumn)
  local previous = nil
  local HitMap={}
  for i=0, dcolumn.steps, 1
  do
      --[[---------------------------------------------
      -- float ValueX = (float)Math.Floor(((float)Hits / (float)Steps) * ((i + Offset) % Steps));
      ]]
      local ValX = math.floor( (dcolumn.hits/dcolumn.steps)*((i+dcolumn.offset)%dcolumn.steps) )
      if previous==ValX then
          HitMap[i]=false;
      else
        HitMap[i]=true;
      end
      previous = ValX
  end
  return HitMap
end
 
