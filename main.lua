--[[============================================================================
main.lua
============================================================================]]--

-- Placeholder for the dialog
local dialog = nil

-- Placeholder to expose the ViewBuilder outside the show_dialog() function
local vb = nil

-- Reload the script whenever this file is saved. 
-- Additionally, execute the attached function.
_AUTO_RELOAD_DEBUG = function()
  
end

-- Read from the manifest.xml file.
class "RenoiseScriptingTool" (renoise.Document.DocumentNode)
  function RenoiseScriptingTool:__init()    
    renoise.Document.DocumentNode.__init(self) 
    self:add_property("Name", "Euclidian Rythm Generator")
    self:add_property("Id", "com.djneonc.EuclidianBeatSequencer")
  end

local manifest = RenoiseScriptingTool()
local ok,err = manifest:load_from("manifest.xml")
local tool_name = manifest:property("Name").value
local tool_id = manifest:property("Id").value


--------------------------------------------------------------------------------
-- Main functions
--------------------------------------------------------------------------------

-- This example function is called from the GUI below.
-- It will return a random string. The GUI function displays 
-- that string in a dialog.
local function get_greeting()
  local words = {"Hello world!", "Nice to meet you :)", "Hi there!"}
  local id = math.random(#words)
  return words[id]
end


local function build_column(tHits,tOffset,tNote,tVolume,tIns,tNoteCol)
  
  local pattern_iter = renoise.song().pattern_iterator
  local pattern_index =  renoise.song().selected_pattern_index
  local track_index =  renoise.song().selected_track_index
  local instrument_index = renoise.song().selected_instrument_index
  
  local num_lines = renoise.song().patterns[pattern_index].number_of_lines 
  
  local EMPTY_VOLUME = renoise.PatternLine.EMPTY_VOLUME
  local EMPTY_INSTRUMENT = renoise.PatternLine.EMPTY_INSTRUMENT
  
  local previous = nil
  local itr = 0
  for pos,line in pattern_iter:lines_in_pattern_track(pattern_index, track_index) do
    
    if not table.is_empty(line.note_columns)then

          local note_column = line:note_column(tNoteCol)
          note_column:clear()
            
          ------------------------------------------------
          -- float ValueX = (float)Math.Floor(((float)Hits / (float)Steps) * ((i + Offset) % Steps));
          local ValX = math.floor( (tHits/num_lines)*((itr+tOffset)%num_lines) )
          if previous==ValX then
              --Nothing
          else
              note_column.note_value=tNote
              note_column.instrument_value=tIns
              note_column.volume_value=tVolume
          end
          previous = ValX
    end
    itr=itr+1
  end
    
end



--------------------------------------------------------------------------------
-- GUI
--------------------------------------------------------------------------------

local function show_dialog()

  -- This block makes sure a non-modal dialog is shown once.
  -- If the dialog is already opened, it will be focused.
  if dialog and dialog.visible then
    dialog:show()
    return
  end
  
  -- The ViewBuilder is the basis
  vb = renoise.ViewBuilder()
  
  local pattern_index =  renoise.song().selected_pattern_index
  local num_lines = renoise.song().patterns[pattern_index].number_of_lines 
  local mHitsDisplay = vb:value{
   value=16
  }
  local mHitsBox = vb:rotary{
    value = 16,
    min = 1,
    max = num_lines,
    default=16,
    notifier=function(number)
      mHitsDisplay.value=math.floor(number)
    end
  }
  
  local mNoteStrText = vb:text{text="C - 3"}
  local function UpdateNoteName(number)
      local NoteName = nil
      local subnote = number%12
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
      local oct = math.floor(number/12)
      mNoteStrText.text=NoteName .. " - " .. tostring(oct)
  end
  local mOffsetBox = vb:valuebox{value = 0}
  local mVeloBox = vb:minislider{
    value = 100,
    min=0,
    max=127,
    default=100
  }
  local mNoteBox = vb:valuebox{
    value = 36,
    min = 0,
    max = 119,
    notifier = UpdateNoteName
  }
  local mInsBox = vb:valuebox{value=0}
  local mNoteCol = vb:valuebox{
    value=1,
    min=1
  }
  -- The content of the dialog, built with the ViewBuilder.
  local content = vb:vertical_aligner {
    width=255,
    margin = 10,
    vb:horizontal_aligner{
      mode="justify",
      vb:column{
        vb:text{
         text="Insturment"
        }
      },
      vb:column{
        mInsBox
      },
      vb:column{
      }
    },
    vb:horizontal_aligner{
      mode="justify",
     vb:column{
        vb:text{
         text="Note Column"
        }
     },
     vb:column{
       mNoteCol
     },
     vb:column{
     }
    },
    
    vb:horizontal_aligner{
      mode="justify",
      vb:column{
        vb:text{
         text = "Number Of Hits"
       }
      },
      vb:column{
        mHitsBox
      },
      vb:column{
        mHitsDisplay
      }
    },
    
    vb:horizontal_aligner{
      mode="justify",
      vb:column{    
        vb:text{
         text = "Offset"
        }
      },
      vb:column{
        mOffsetBox
      },
      vb:column{
      }
    },
    
    vb:horizontal_aligner{
      mode="justify",
      vb:column{
        vb:text{
         text="Drum Note"
        }
      },
      vb:column{
        mNoteBox
      },
      vb:column{
        mNoteStrText
      }
    },
    
    vb:horizontal_aligner{
      mode="justify",
      vb:column{
       vb:text{
         text="Velocity"
        }
      },
      vb:column{
        mVeloBox
      },
      vb:column{
      }
    },
    vb:button{
      text="Generate",
      pressed=function()
        build_column(math.floor(mHitsBox.value), mOffsetBox.value, mNoteBox.value, mVeloBox.value, mInsBox.value, mNoteCol.value)
      end
    }
  } 
  
  -- A custom dialog is non-modal and displays a user designed
  -- layout built with the ViewBuilder.   
  dialog = renoise.app():show_custom_dialog(tool_name, content)  
  
  
  -- A custom prompt is a modal dialog, restricting interaction to itself. 
  -- As long as the prompt is displayed, the GUI thread is paused. Since 
  -- currently all scripts run in the GUI thread, any processes that were running 
  -- in scripts will be paused. 
  -- A custom prompt requires buttons. The prompt will return the label of 
  -- the button that was pressed or nil if the dialog was closed with the 
  -- standard X button.  
  --[[ 
    local buttons = {"OK", "Cancel"}
    local choice = renoise.app():show_custom_prompt(
      tool_name, 
      content, 
      buttons
    )  
    if (choice == buttons[1]) then
      -- user pressed OK, do something  
    end
  --]]
end


--------------------------------------------------------------------------------
-- Menu entries
--------------------------------------------------------------------------------

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:"..tool_name.."...",
  invoke = show_dialog  
}


--------------------------------------------------------------------------------
-- Key Binding
--------------------------------------------------------------------------------

--[[
renoise.tool():add_keybinding {
  name = "Global:Tools:" .. tool_name.."...",
  invoke = show_dialog
}
--]]


--------------------------------------------------------------------------------
-- MIDI Mapping
--------------------------------------------------------------------------------

--[[
renoise.tool():add_midi_mapping {
  name = tool_id..":Show Dialog...",
  invoke = show_dialog
}
--]]
