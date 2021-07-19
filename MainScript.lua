local setf = script.Parent.settings
local ui = script.Parent.UI.Holder
local ss = game:GetService("Selection")

local setting = {
	["Intensity"] = ui.set.Intensity
}

local function reflect(vector, normal)
	return -2 * vector:Dot(normal) * normal + vector;
end

local function CreateLightRays (multi)
	for i,light in pairs(workspace.GI_Lights:GetChildren()) do
		-- Ray
		local orig = light.Position
		local dir = light.CFrame.LookVector
		local hit,pos,norm = workspace:FindPartOnRay(Ray.new(orig, dir * 5000))
		local hit2,pos2,norm2 = workspace:FindPartOnRay(Ray.new(pos,pos + reflect(pos - orig, norm))) -- look at ray
		--local h,l,nn = workspace:FindPartOnRay(Ray.new(pos2, pos2 + reflect(pos2 - pos, n)))
		
		light.Transparency = 1
		light.SurfaceLight.Enabled = false
		
		if hit then
			local partEmitter = Instance.new("Part", workspace.GI_OBJ)
			local newLight = Instance.new("PointLight", partEmitter)
			
			partEmitter.CFrame = CFrame.new(pos)
			partEmitter.Anchored = true
			partEmitter.CanCollide = false
			partEmitter.Size = Vector3.new(0.1,0.1,0.1)
			partEmitter.Name = "Emiiter"
			partEmitter.Transparency = 1
			newLight.Range = 70
			newLight.Shadows = true
			
			newLight.Brightness = 0.5 * multi
			newLight.Color = hit.Color
			
			local partEmitter2 = partEmitter:Clone();partEmitter2.Parent = workspace.GI_OBJ
			partEmitter2.PointLight:Destroy()
			local newLight2 = newLight:Clone();newLight2.Parent = partEmitter2
			
			if hit2 then
				partEmitter2.CFrame = CFrame.new(pos2)
				newLight2.Color = hit2.Color
				newLight2.Brightness = 0.1 * multi
				newLight2.Range = 60
				--newLight2.Shadows = false
			end
			
			if light.tinted.Value == true then
				if ui.set.tint.e.Visible == true then
					local nl = newLight:Clone()
					nl.Parent = partEmitter
					nl.Color = light.tint.Value
					nl.Name = "p2"
					
					local nl2 = nl:Clone()
					nl2.Parent = partEmitter2
				
					nl.Brightness = (0.4 * multi)/2
					newLight.Brightness = (0.4 * multi)/2
					newLight2.Brightness = (0.05 * multi)/2
					nl2.Brightness = (0.05 * multi)/2
					newLight.Color = hit.Color
				end
			end
		end
	end
end

function resetLights ()
	for i,v in pairs(workspace.GI_OBJ:GetChildren()) do
		v:Destroy()
	end
	
	for i,c in pairs(workspace.GI_Lights:GetChildren()) do
		c.Transparency = 0
		c.SurfaceLight.Enabled = true
	end
end

function createfolders ()
	if workspace:FindFirstChild("GI_OBJ") then else
		Instance.new("Folder",workspace).Name = "GI_OBJ"
	end
	
	if workspace:FindFirstChild("GI_Lights") then else
		Instance.new("Folder",workspace).Name = "GI_Lights"
	end
end

function addlightstoOBJ (obj,tint, color)
	for i = 1, 6 do
		local nl = script.Parent.Items.light:Clone()
		nl.Parent = workspace.GI_Lights
		nl.Position = obj.Position
		local m = script.Parent.Items.IsGen:Clone()
		m.Parent = nl
		
		if tint then
			nl.tinted.Value = true
			nl.tint.Value = color
		end
		
		if i==1 then
			nl.Orientation = obj.Orientation 	
		elseif i==2 then
			nl.Orientation = Vector3.new(90,0,0)
		elseif i==3 then
			nl.Orientation = Vector3.new(180,0,0)
		elseif i==4 then
			nl.Orientation = Vector3.new(-90,0,0)
		elseif i==5 then
			nl.Orientation = Vector3.new(0,90,0)
		elseif i==6 then
			nl.Orientation = Vector3.new(0,-90,0)
		end
	end
end

function addlights ()
	resetLights()
	
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name == "IsGen" then
			v.Parent:Destroy()
		end
	end
	
	for i,obj in pairs(ss:Get()) do
		if obj:IsA("BasePart") then
			local l = obj:FindFirstChildOfClass("PointLight")
			
			if l then
				addlightstoOBJ(obj,true, l.Color)
			else
				addlightstoOBJ(obj)
			end
		end
	end
end

--// Plugin Stuff \\--
local toolbar = plugin:CreateToolbar("Global Illumination")


local lightButton = toolbar:CreateButton(
	"LightEditor",
	"Light Editor Panel",
	"rbxassetid://5806779841",
	"Light Editor"
)

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,  --: This is the initial dockstate of the widget
	false,  --: Initial state, enabled or not
	false,  --: Can override previous state?
	400,    --: Default width
	500,    --: Default height
	400,    --: Minimum width
	500     --: Minimum height
)

local lightPanel = plugin:CreateDockWidgetPluginGui("LightPanel", widgetInfo)
lightPanel.Title = "GI Panel"

ui.Parent = lightPanel

lightButton.Click:Connect(function() lightPanel.Enabled = not lightPanel.Enabled end)

--// Plugin UI
ui.insert.MouseButton1Down:Connect(function()
	createfolders()
	local nl = script.Parent.Items.light:Clone()
	nl.Parent = workspace.GI_Lights
	
	ss:Set({nl})
end)

ui.delgi.MouseButton1Down:Connect(function()
	createfolders()
	resetLights()
end)

ui.del.MouseButton1Down:Connect(function()
	for i,v in pairs(workspace.GI_Lights:GetChildren()) do
		v:Destroy()
	end
end)

local baking = false

ui.add.MouseButton1Down:Connect(function()
	addlights()
end)

ui.bake.MouseButton1Down:Connect(function()
	if baking == false then
		baking = true
		
		createfolders() wait() 
		resetLights()
		CreateLightRays(tonumber(setting.Intensity.Text)) 
		
		baking = false
	end
end)

ui.delg.MouseButton1Down:Connect(function()
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name == "IsGen" then
			v.Parent:Destroy()
		end
	end
end)

ui.set.tintt.MouseButton1Down:Connect(function()
	ui.set.tint.e.Visible = not ui.set.tint.e.Visible
end)
