local usePrefixing = true
local tableToConvert = {}
local textToReturn = {}
local hierarchyIteration = 1
do
    textToReturn[1] = "{\n"
    local function serializeString(text)
        if type(text) ~= "string" then
            text = tostring(text)
        end
        return text:gsub("\"", "\\\"")
    end
    local function write(...)
        local t = {...}
        for _, text in pairs(t) do
            table.insert(textToReturn, text)
        end
    end
    local function doIndentation()
        write(string.rep("\t", hierarchyIteration))
    end
    local function writeToTextTable(index, value)
        local prefix
        if usePrefixing == true then
            if type(index) == "number" then
                prefix = index
            elseif type(index) == "string" then
                -- make sure any string index is surrounded by quotes
                local i = tonumber(index)
                prefix = i or ("\"%s\""):format(index)
            else
                -- replace any quotes with string-quotes
                prefix = ("\"%s\""):format(serializeString(index))
            end
        end
        doIndentation()
        write(("[%s] = "):format(prefix))
        if type(value) == "table" then
            write("{", "\n")
            hierarchyIteration += 1
            for i, v in pairs(value) do
                writeToTextTable(i, v)
            end
            hierarchyIteration -= 1
            doIndentation()
            write("}")
        elseif table.find({"number", "boolean", "EnumItem"}, typeof(value)) then
            write(tostring(value))
        elseif table.find({"string"}, typeof(value)) then
            write(("\"%s\""):format(serializeString(value)))
        elseif table.find({"Enum"}, typeof(value)) then
            write(("Enum.%s"):format(tostring(value)))
        elseif typeof(value) == "NumberSequence" then
            write("NumberSequence.new({\n")
            hierarchyIteration += 1
            for i, v in pairs(value.Keypoints) do
                doIndentation()
                write("NumberSequenceKeypoint.new(", v.Time, ", ", v.Value, ", ", v.Envelope, ")")
                if i ~= #value.Keypoints then
                    write(",\n")
                else
                    write("\n")
                end
            end
            hierarchyIteration -= 1
            doIndentation()
            write("})")
        elseif typeof(value) == "NumberSequenceKeypoint" then
            write("NumberSequenceKeypoint.new(", value.Time, ", ", value.Value, ", ", value.Envelope, ")")
        elseif typeof(value) == "Vector3" then
            write("Vector3.new(", tostring(value), ")")
        elseif typeof(value) == "Vector2" then
            write("Vector2.new(", tostring(value), ")")
        elseif typeof(value) == "CFrame" then
            if not pcall(function() write("CFrame.new(", table.concat({table.unpack(value:GetComponents())}, ", "), ")") end) then
                write("CFrame.identity")
            end
        elseif typeof(value) == 'function' then
            write("function(...) end")
        elseif typeof(value) == "TweenInfo" then
            write("TweenInfo.new(", value.Time, ", ", tostring(value.EasingStyle), ", ", tostring(value.EasingDirection), ", ", value.RepeatCount, ", ", value.Reverses == true and "true" or "false", ", ", value.DelayTime, ")")
        elseif typeof(value) == "Region3int16" then
            write("Region3int16.new(Vector3int16.new(", tostring(value.Min), ")", "Vector3int16.new(", tostring(value.Max), "))")
        elseif typeof(value) == "Vector3int16" then
            write("Vector3int16.new(", tostring(value), ")")
        elseif typeof(value) == "UDim" then
            write("UDim.new(", value.Scale, ", ", value.Offset, ")")
        elseif typeof(value) == "UDim2" then
            write("UDim2.new(", value.X.Scale, ", ", value.X.Offset, ", ", value.Y.Scale, ", ", value.Y.Offset, ")")
        elseif typeof(value) == "ColorSequence" then
            write("ColorSequence.new({\n")
            hierarchyIteration += 1
            for i, v in pairs(value.Keypoints) do
                doIndentation()
                write("ColorSequenceKeypoint.new(", v.Time, ", Color3.fromRGB(", math.floor(v.Value.R * 255), ", ", math.floor(v.Value.G * 255), ", ", math.floor(v.Value.B * 255), "))")
                if i ~= #value.Keypoints then
                    write(",\n")
                else
                    write("\n")
                end
            end
            hierarchyIteration -= 1
            doIndentation()
            write("})")
        elseif typeof(value) == "Color3" then
            write("Color3.fromRGB(", math.floor(value.R * 255), ", ", math.floor(value.G * 255), ", ", math.floor(value.B * 255), ")")
        elseif typeof(value) == "BrickColor" then
            write("BrickColor.new(\"", value.Name, "\")")
        end
        local lastvalue
        table.foreachi(tableToConvert, function(i, v)
            if i == table.getn(tableToConvert) and v == value then
                lastvalue = v
            end
        end)
        if value ~= lastvalue then
            write(",\n")
        end
    end
    for index, value in pairs(tableToConvert) do
        writeToTextTable(index, value)
    end
    table.insert(textToReturn, "\n}")
end
setclipboard(table.concat(textToReturn))
