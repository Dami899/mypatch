UV.RegisterSpeedometer( "nightrunners", "NIGHTRUNNERS" )

-- [[ Convars ]] --
-- Speedometer
CreateClientConVar("uvspeedo_nightrunners_x", 0.875, true, false)
CreateClientConVar("uvspeedo_nightrunners_y", 0.825, true, false)

CreateClientConVar("uvspeedo_nightrunners_shownitrous", 0, true, false)
CreateClientConVar("uvspeedo_nightrunners_gauge", 1, true, false)

CreateClientConVar("uvspeedo_nightrunners_col_maingauges_r", 38, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_maingauges_g", 225, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_maingauges_b", 0, true, false)

CreateClientConVar("uvspeedo_nightrunners_col_mainneedles_r", 255, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_mainneedles_g", 0, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_mainneedles_b", 0, true, false)

CreateClientConVar("uvspeedo_nightrunners_col_tempgauges_r", 38, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_tempgauges_g", 225, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_tempgauges_b", 0, true, false)

CreateClientConVar("uvspeedo_nightrunners_col_fuelgauges_r", 38, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_fuelgauges_g", 225, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_fuelgauges_b", 0, true, false)

CreateClientConVar("uvspeedo_nightrunners_col_tempneedles_r", 255, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_tempneedles_g", 0, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_tempneedles_b", 0, true, false)

CreateClientConVar("uvspeedo_nightrunners_col_fuelneedles_r", 255, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_fuelneedles_g", 0, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_fuelneedles_b", 0, true, false)

CreateClientConVar("uvspeedo_nightrunners_col_redline_r", 255, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_redline_g", 0, true, false)
CreateClientConVar("uvspeedo_nightrunners_col_redline_b", 0, true, false)

UV_UI.speedometer = UV_UI.speedometer or {}
UV_UI.speedometer.nightrunners = UV_UI.speedometer.nightrunners or {}
UVMenu.CustomizeSpeedo = UVMenu.CustomizeSpeedo or {}

UVMenu.CustomizeSpeedo.nightrunners = function()
    UVMenu.CurrentMenu = UVMenu:Open({
        Name = " ",
        Width  = UV.ScaleW(1250),
        Height = UV.ScaleH(760),
        Description = true,
        -- ColorPreview = true,
        UnfocusClose = true,
        Tabs = {
            { TabName = "uv.ui.speedometer.cust",
            { type = "label", text = "NIGHTRUNNERS" },
            { type = "button", text = "uv.back", playsfx = "clickback", prompts = {"uv.prompt.return"},
            func = function(self2) UVMenu.OpenMenu(UVMenu.Settings) end
        },
        { type = "slider", text = "uv.ui.xaxis", desc = "uv.ui.xaxis.desc", convar = "uvspeedo_nightrunners_x", min = 0, max = 1, decimals = 3 },
        { type = "slider", text = "uv.ui.yaxis", desc = "uv.ui.yaxis.desc", convar = "uvspeedo_nightrunners_y", min = 0, max = 1, decimals = 3 },
        { type = "slider", text = "uv.speedo", convar = "uvspeedo_nightrunners_gauge", min = 1, max = 3, decimals = 0 },
        { type = "bool", text = "uv.speedo.shownitrous", desc = "uv.speedo.shownitrous.desc", convar = "uvspeedo_nightrunners_shownitrous", cond = function() return cffunctions end },
        { type = "coloralpha", text = "uv.speedo.face", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_nightrunners_col_maingauges" },
        { type = "coloralpha", text = "uv.speedo.needle", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_nightrunners_col_mainneedles" },
        { type = "coloralpha", text = "uv.speedo.tempface", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_nightrunners_col_tempgauges" },
        { type = "coloralpha", text = "uv.speedo.fuelface", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_nightrunners_col_fuelgauges" },
        { type = "coloralpha", text = "uv.speedo.tempneedle", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_nightrunners_col_tempneedles" },
        { type = "coloralpha", text = "uv.speedo.fuelneedle", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_nightrunners_col_fuelneedles" },
        { type = "coloralpha", text = "uv.speedo.redline", desc = "uv.ui.menu.col.desc", convar = "uvspeedo_nightrunners_col_redline" },
    },
}
})
end

local function CalcLerp( v1, v2, vMax, responsiveness )
    local vLerp = Lerp( FrameTime() * responsiveness, v1, v2 )
    local vFrac = math.Clamp( vLerp / vMax, 0, 1 )
    return vLerp, vFrac
end

local data = {
    ['colors'] = {},
    ['posX'] = 0,
    ['posY'] = 0,
    ['screenX'] = 0,
    ['screenY'] = 0,
    ['speed'] = 0,
    ['speedname'] = '',
    ['gear'] = 0,
    ['gearText'] = '',
    ['rpm'] = 0,
    ['maxrpm'] = 0,
    ['throttle'] = 0,
    ['redlining'] = false,
    ['redlinestrength'] = 0,
    ['health'] = 0,
    ['nitrousenabled'] = false,
    ['nitrous'] = 0,
    ['speedbreakerenabled'] = false,
    ['speedbreaker'] = 0,
}

UV_UI.speedometer.nightrunners.settings = {
    styles = {
        [1] = {
            {
                type = 'Cluster',
                name = 'RPM',
                data = {
                    value = function()
                        return data.rpm
                    end,
                    --name = 'rpm',
                    max = function() 
                        return data.maxrpm
                    end
                },
                renderData = {
                    position = {
                        x = -0.025,
                        y = -0.2
                    },
                    additional = {
                        [1] = {
                            mat = UVMaterials["TACHO1_NR_BIG_BACKING_GLASS"],
                            scale = 0.3,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['backingGlass']
                            end
                        },
                        [2] = {
                            mat = UVMaterials["TACHO1_NR_BIG_BACKING"],
                            scale = 0.3,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = color_black
                        },
                        [3] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.18,
                            offsets = {
                                x = 0,
                                y = 0.018
                            },
                            color = function() 
                                return data.rpm ~= 0 and data.colors['mainNeedle'] or Color( 0, 0, 0, 0 )
                            end
                        },
                        [4] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLASS"],
                            scale = 0.05,
                            offsets = {
                                x = 0,
                                y = 0.018
                            },
                            color = function() 
                                return data.colors['switchedOffLight']
                            end
                        },
                    },
                    needle = {
                        animation = {
                            idle = 20,
                            max = 235,
                            direction = -1,
                            velocity = 8
                        },
                        scale = 0.3,
                        offsets = {
                            x = 0,
                            y = 0.018
                        },
                        lowWobble = {
                            min = 0.05,
                            max = 0.2,
                            intensity = 2
                        },
                        redlining = {
                            intensity = 4
                        },
                        mat = UVMaterials["TACHO1_NR_NEEDLE"],
                        color = function() 
                            return data.rpm ~= 0 and data.colors['mainNeedle'] or Color( data.colors['mainNeedle'].r / 3, data.colors['mainNeedle'].g / 3, data.colors['mainNeedle'].b / 3, 210 )
                        end
                    },
                    gauge = {
                        mat = UVMaterials["TACHO1_NR_RPM_GAUGE"],
                        scale = 0.3,
                        redline = {
                            mat = UVMaterials["TACHO1_NR_REDLINE"],
                            scale = 0.3,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.rpm ~= 0 and data.colors['redline'] or Color( data.colors['redline'].r / 3, data.colors['redline'].g / 3, data.colors['redline'].b / 3, 210 )
                            end
                        },
                        offsets = {
                            x = 0,
                            y = 0
                        },
                        color = function() 
                            return data.rpm ~= 0 and data.colors['mainGauge'] or data.colors['switchedOffLight']
                        end
                    }
                }
            },
            {
                type = 'Cluster',
                name = 'Speedo',
                data = {
                    value = function()
                        return data.speed
                    end,
                    --name = 'speed',
                    max = 250
                },
                renderData = {
                    position = {
                        x = -0.1,
                        y = 0.01
                    },
                    additional = {
                        [1] = {
                            mat = UVMaterials["TACHO1_NR_BIG_BACKING_GLASS"],
                            scale = 0.3,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['backingGlass']
                            end
                        }, 
                        [2] = {
                            mat = UVMaterials["TACHO1_NR_BIG_BACKING"],
                            scale = 0.3,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = color_black
                        },
                        [3] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.18,
                            offsets = {
                                x = 0,
                                y = 0.019
                            },
                            color = function() 
                                return data.rpm ~= 0 and data.colors['mainNeedle'] or Color( 0, 0, 0, 0 )
                            end
                        },
                        [4] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLASS"],
                            scale = 0.05,
                            offsets = {
                                x = 0,
                                y = 0.019
                            },
                            color = function() 
                                return data.colors['switchedOffLight']
                            end
                        },
                        [5] = {
                            mat = UVMaterials["SHARED_DASH_NR_ENGINE_OVERHEAT"],
                            scale = 0.023,
                            offsets = {
                                x = 0.055,
                                y = -0.143
                            },
                            color = function() 
                                return data.rpm ~= 0 and not GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and data.tempLerp >= 0.91 and Color(255,0,0,255) or Color(0,0,0,0)
                            end
                        },
                    },
                    needle = {
                        animation = {
                            idle = 20,
                            max = 250,
                            direction = -1,
                            velocity = 8
                        },
                        scale = 0.3,
                        offsets = {
                            x = 0,
                            y = 0.0185
                        },
                        mat = UVMaterials["TACHO1_NR_NEEDLE"],
                        color = function() 
                            return data.rpm ~= 0 and data.colors['mainNeedle'] or Color( data.colors['mainNeedle'].r / 3, data.colors['mainNeedle'].g / 3, data.colors['mainNeedle'].b / 3, 210 )
                        end
                    },
                    gauge = {
                        mat = UVMaterials["TACHO1_NR_SPEEDO_GAUGE"],
                        scale = 0.3,
                        offsets = {
                            x = 0,
                            y = 0
                        },
                        color = function() 
                            return data.rpm ~= 0 and data.colors['mainGauge'] or data.colors['switchedOffLight']
                        end
                    },
                }
            },
            {
                type = 'Cluster',
                name = 'Temperature',
                data = {
                    value = function()
                        return data.rpm == 0 and 0 or (GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and (data.speedbreakerenabled and data.maxtemp * data.speedbreaker or data.maxtemp) or data.tempLerp)
                    end,
                    --name = speed,
                    max = function()
                        return 1
                    end
                },
                renderData = {
                    position = {
                        x = 0.009,
                        y = 0.08
                    },
                    additional = {
                        [1] = {
                            mat = UVMaterials["TACHO1_NR_TEMP_GAUGE_GLASS"],
                            scale = 0.28,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['backingGlass']
                            end
                        },
                        [2] = {
                            mat = UVMaterials["TACHO1_NR_TEMP_GAUGE_BACKING"],
                            scale = 0.28,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = color_black
                        },
                        [3] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.18,
                            offsets = {
                                x = 0.018,
                                y = 0.027
                            },
                            color = function() 
                                return Color(data.colors['tempNeedle'].r, data.colors['tempNeedle'].g, data.colors['tempNeedle'].b, data.rpm == 0 and 0 or 63)
                            end
                        },
                        [4] = {
                            mat = UVMaterials["TACHO1_NR_SMALL_NEEDLE_GLASS"],
                            scale = 0.25,
                            offsets = {
                                x = 0.018,
                                y = 0.027
                            },
                            color = function() 
                                return data.colors['switchedOffLight']
                            end
                        },
                        [5] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.1,
                            offsets = {
                                x = -0.006,
                                y = 0.014
                            },
                            color = function() 
                                return data.rpm ~= 0 and not GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and data.tempLerp >= 0.91 and Color(255,0,0,75) or Color(0,0,0,0)
                            end
                        },
                        [6] = {
                            mat = UVMaterials["SHARED_DASH_NR_LIGHT"],
                            scale = 0.014,
                            offsets = {
                                x = -0.006,
                                y = 0.014
                            },
                            color = function() 
                                return data.rpm ~= 0 and not GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and data.tempLerp >= 0.91 and Color(255,0,0,150) or Color(0,0,0,0)
                            end
                        },

                    },
                    gauge = {
                        mat = UVMaterials["TACHO1_NR_TEMP_GAUGE"],
                        scale = 0.28,
                        offsets = {
                            x = 0,
                            y = 0
                        },
                        color = function() 
                            return data.rpm ~= 0 and data.colors['tempGauge'] or data.colors['switchedOffLight']
                        end
                    },
                    needle = {
                        animation = {
                            idle = 7,
                            max = 75,
                            direction = -1,
                            velocity = function() 
                                return 3
                            end
                        },
                        scale = 0.21,
                        offsets = {
                            x = 0.018,
                            y = 0.027
                        },
                        mat = UVMaterials["TACHO1_NR_SMALL_NEEDLE"],
                        color = function() 
                            return data.rpm ~= 0 and data.colors['tempNeedle'] or Color( data.colors['tempNeedle'].r / 3, data.colors['tempNeedle'].g / 3, data.colors['tempNeedle'].b / 3, 210 )
                        end
                    }
                }
            },
            {
                type = 'Cluster',
                name = 'Fuel',
                data = {
                    value = function()
                        return data.rpm == 0 and 0 or (GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and (data.nitrousenabled and 100 * data.nitrous or 100) or data.fuelLerp)
                    end,
                    --name = fuel,
                    max = 1
                },
                renderData = {
                    position = {
                        x = 0.03,
                        y = -0.03
                    },
                    additional = {
                        [1] = {
                            mat = UVMaterials["TACHO1_NR_FUEL_GAUGE_GLASS"],
                            scale = 0.28,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['backingGlass']
                            end
                        },
                        [2] = {
                            mat = UVMaterials["TACHO1_NR_FUEL_GAUGE_BACKING"],
                            scale = 0.28,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = color_black
                        },
                        [3] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.18,
                            offsets = {
                                x = -0.02,
                                y = 0.029
                            },
                            color = function() 
                                return Color(data.colors['fuelNeedle'].r, data.colors['fuelNeedle'].g, data.colors['fuelNeedle'].b, data.rpm == 0 and 0 or 63)
                            end
                        },
                        [4] = {
                            mat = UVMaterials["TACHO1_NR_SMALL_NEEDLE_GLASS"],
                            scale = 0.25,
                            offsets = {
                                x = -0.02,
                                y = 0.029
                            },
                            color = function() 
                                return data.colors['switchedOffLight']
                            end
                        },
                        [5] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.1,
                            offsets = {
                                x = 0.003,
                                y = 0.019
                            },
                            color = function() 
                                return data.rpm ~= 0 and not GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and data.fuelLerp <= 0.2 and Color(255,0,0,75) or Color(0,0,0,0)
                            end
                        },
                        [6] = {
                            mat = UVMaterials["SHARED_DASH_NR_LIGHT"],
                            scale = 0.014,
                            offsets = {
                                x = 0.003,
                                y = 0.019
                            },
                            color = function() 
                                return data.rpm ~= 0 and not GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and data.fuelLerp <= 0.2 and Color(255,0,0,150) or Color(0,0,0,0)
                            end
                        },
                    },
                    needle = {
                        animation = {
                            idle = -189,
    	                    max = -255,
    	                    direction = -1,
                            velocity = 3
                        },
                        scale = 0.21,
                        offsets = {
                            x = -0.02,
                            y = 0.029
                        },
                        mat = UVMaterials["TACHO1_NR_SMALL_NEEDLE"],
                        color = function() 
                            return data.rpm ~= 0 and data.colors['fuelNeedle'] or Color( data.colors['fuelNeedle'].r / 3, data.colors['fuelNeedle'].g / 3, data.colors['fuelNeedle'].b / 3, 210 )
                        end
                    },
                    gauge = {
                        mat = UVMaterials["TACHO1_NR_FUEL_GAUGE"],
                        scale = 0.28,
                        offsets = {
                            x = 0,
                            y = 0
                        },
                        color = function() 
                            return data.rpm ~= 0 and data.colors['fuelGauge'] or data.colors['switchedOffLight']
                        end
                    }
                }
            },
            {
                type = 'Gears',
                data = {
                    value = function()
                        return data.gear
                    end,
                },
                renderData = {
                    position = {
                        x = -0.13,
                        y = 0.08
                    },
                    additional = {},
                    gears = {
                        font = "UVNightRunnersLCDFont-Tiny1",
                        textAlign = TEXT_ALIGN_LEFT,
                        textColor = function()
                            return data.colors['mainGauge']
                        end,
                        offsets = {
                            x = 0,
                            y = 0
                        },
                        icon = {
                            upMat = UVMaterials["SHARED_DASH_NR_SHIFT_UP_ICON"],
                            upColor = function()
                                return data.colors['mainGauge']
                            end,
                            downMat = UVMaterials["SHARED_DASH_NR_SHIFT_DOWN_ICON"],
                            downColor = function()
                                return data.colors['mainGauge']
                            end,
                            offsets = {
                                x = -0.01,
                                y = 0.02
                            },
                            scale = 0.02,
                            color = function()
                                return data.colors['mainGauge']
                            end
                        }
                    }
                }
            },
            {
                type = 'Odometer',
                data = {
                    value = function()
                        return Glide.currentVehicle.__ODO
                    end,
                },
                renderData = {
                    position = {
                        x = -0.08,
                        y = 0.020
                    },
                    additional = {
                        [1] = {
                            mat = UVMaterials["SHARED_DASH_NR_ODOMETER"],
                            scale = 0.26,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            sizeOffsets = {
                                x = 0.005,
                                y = 0
                            },
                            color = function()
                                return data.rpm == 0 and data.colors['switchedOffLight'] or color_white
                            end
                        }
                    },
                    display = {
                        unit = {
                            text = "KM",
                            offset = {
                                x = -0.027,
                                y = 0.074
                            },
                            font = "UVNightRunnersLCDFont-ThinTiny2",
                            color = function()
                                return color_black
                            end,
                            align = TEXT_ALIGN_LEFT,
                            outlineWidth = 0.5,
                            outlineColor = function()
                                return color_black
                            end,
                        },
                        value = {
                            text = function()
                                return string.Comma(math.floor(Glide.currentVehicle.__ODO), "'")
                            end,
                            offset = {
                                x = 0.029,
                                y = 0.066
                            },
                            font = "UVNightRunnersLCDFont-Tiny2NoShadow",
                            color = function()
                                return color_black
                            end,
                            align = TEXT_ALIGN_RIGHT,
                            outlineWidth = 0.5,
                            outlineColor = function()
                                return color_black
                            end,
                        }
                    }
                }
            }
        },
        [2] = {
            {
                type = 'Cluster',
                name = 'RPM',
                data = {
                    value = function()
                        return data.rpm
                    end,
                    --name = 'rpm',
                    max = function() 
                        return data.maxrpm
                    end
                },
                renderData = {
                    position = {
                        x = -0.025,
                        y = -0.2
                    },
                    additional = {
                        [1] = {
                            mat = UVMaterials["TACHO2_NR_BIG_BACKING_GLASS"],
                            scale = 0.32,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['backingGlass']
                            end
                        },
                        [2] = {
                            mat = UVMaterials["TACHO2_NR_BIG_BACKING"],
                            scale = 0.32,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = color_black
                        },
                        [3] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.2,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.rpm ~= 0 and data.colors['mainNeedle'] or Color( 0, 0, 0, 0 )
                            end
                        },
                        [4] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLASS"],
                            scale = 0.05,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['switchedOffLight']
                            end
                        },
                        [5] = {
                            mat = UVMaterials["SHARED_DASH_NR_ENGINE_OVERHEAT"],
                            scale = 0.023,
                            offsets = {
                                x = 0,
                                y = 0.05
                            },
                            color = function() 
                                return data.rpm ~= 0 and not GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and data.tempLerp >= 0.91 and Color(255,0,0,255) or Color(0,0,0,0)
                            end
                        },
                    },
                    needle = {
                        animation = {
                            idle = 36,
                            max = 275,
                            direction = -1,
                            velocity = 8
                        },
                        scale = 0.31,
                        offsets = {
                            x = 0,
                            y = 0
                        },
                        lowWobble = {
                            min = 0.05,
                            max = 0.2,
                            intensity = 2
                        },
                        redlining = {
                            intensity = 4
                        },
                        mat = UVMaterials["TACHO2_NR_BIG_NEEDLE"],
                        color = function() 
                            return data.rpm ~= 0 and data.colors['mainNeedle'] or Color( data.colors['mainNeedle'].r / 3, data.colors['mainNeedle'].g / 3, data.colors['mainNeedle'].b / 3, 210 )
                        end
                    },
                    gauge = {
                        mat = UVMaterials["TACHO2_NR_RPM_GAUGE"],
                        scale = 0.32,
                        redline = {
                            mat = UVMaterials["TACHO2_NR_REDLINE"],
                            scale = 0.32,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.rpm ~= 0 and data.colors['redline'] or Color( data.colors['redline'].r / 3, data.colors['redline'].g / 3, data.colors['redline'].b / 3, 210 )
                            end
                        },
                        offsets = {
                            x = 0,
                            y = 0
                        },
                        color = function() 
                            return data.rpm ~= 0 and data.colors['mainGauge'] or data.colors['switchedOffLight']
                        end
                    }
                }
            },
            {
                type = 'Cluster',
                name = 'Speedo',
                data = {
                    value = function()
                        return data.speed
                    end,
                    --name = 'speed',
                    max = 310
                },
                renderData = {
                    position = {
                        x = -0.1,
                        y = 0.01
                    },
                    additional = {
                        [1] = {
                            mat = UVMaterials["TACHO2_NR_BIG_BACKING_GLASS"],
                            scale = 0.32,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['backingGlass']
                            end
                        }, 
                        [2] = {
                            mat = UVMaterials["TACHO2_NR_BIG_BACKING"],
                            scale = 0.32,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = color_black
                        },
                        [3] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.2,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.rpm ~= 0 and data.colors['mainNeedle'] or Color( 0, 0, 0, 0 )
                            end
                        },
                        [4] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLASS"],
                            scale = 0.05,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['switchedOffLight']
                            end
                        },
                    },
                    needle = {
                        animation = {
                            idle = 37.5,
                            max = 297,
                            direction = -1,
                            velocity = 8
                        },
                        scale = 0.32,
                        offsets = {
                            x = 0,
                            y = 0
                        },
                        mat = UVMaterials["TACHO2_NR_BIG_NEEDLE"],
                        color = function() 
                            return data.rpm ~= 0 and data.colors['mainNeedle'] or Color( data.colors['mainNeedle'].r / 3, data.colors['mainNeedle'].g / 3, data.colors['mainNeedle'].b / 3, 210 )
                        end
                    },
                    gauge = {
                        mat = UVMaterials["TACHO2_NR_SPEEDO_GAUGE"],
                        scale = 0.32,
                        offsets = {
                            x = 0,
                            y = 0
                        },
                        color = function() 
                            return data.rpm ~= 0 and data.colors['mainGauge'] or data.colors['switchedOffLight']
                        end
                    },
                }
            },
            {
                type = 'Cluster',
                name = 'Temperature',
                data = {
                    value = function()
                        return data.rpm == 0 and 0 or (GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and (data.speedbreakerenabled and data.maxtemp * data.speedbreaker or data.maxtemp) or data.tempLerp)
                    end,
                    --name = speed,
                    max = function()
                        return 1
                    end
                },
                renderData = {
                    position = {
                        -- x = 0.009,
                        -- y = 0.08
                        x = 0.063,
                        y = -0.06
                    },
                    additional = {
                        [1] = {
                            mat = UVMaterials["TACHO2_NR_SMALL_BACKING_GLASS"],
                            scale = 0.28,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['backingGlass']
                            end
                        },
                        [2] = {
                            mat = UVMaterials["TACHO2_NR_SMALL_BACKING"],
                            scale = 0.28,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = color_black
                        },
                        [3] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.18,
                            offsets = {
                                x = -0.005,
                                y = 0
                            },
                            color = function() 
                                return Color(data.colors['tempNeedle'].r, data.colors['tempNeedle'].g, data.colors['tempNeedle'].b, data.rpm == 0 and 0 or 63)
                            end
                        },
                        [4] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLASS"],
                            scale = 0.04,
                            offsets = {
                                x = -0.005,
                                y = 0
                            },
                            color = function() 
                                return data.colors['switchedOffLight']
                            end
                        },
                        [5] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.04,
                            offsets = {
                                x = 0.015,
                                y = 0
                            },
                            color = function() 
                                return data.rpm ~= 0 and not GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and data.tempLerp >= 0.91 and Color(255,0,0,75) or Color(0,0,0,0)
                            end
                        },
                        [6] = {
                            mat = UVMaterials["SHARED_DASH_NR_LIGHT"],
                            scale = 0.014,
                            offsets = {
                                x = 0.015,
                                y = 0
                            },
                            color = function() 
                                return data.rpm ~= 0 and not GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and data.tempLerp >= 0.91 and Color(255,0,0,150) or Color(0,0,0,0)
                            end
                        },

                    },
                    gauge = {
                        mat = UVMaterials["TACHO2_NR_TEMP_GAUGE"],
                        scale = 0.3,
                        offsets = {
                            x = 0,
                            y = 0
                        },
                        color = function() 
                            return data.rpm ~= 0 and data.colors['tempGauge'] or data.colors['switchedOffLight']
                        end
                    },
                    needle = {
                        animation = {
                            idle = 130,
                            max = 40,
                            direction = -1,
                            velocity = function() 
                                return 3
                            end
                        },
                        scale = 0.3,
                        offsets = {
                            x = -0.005,
                            y = 0
                        },
                        mat = UVMaterials["TACHO2_NR_SMALL_NEEDLE"],
                        color = function() 
                            return data.rpm ~= 0 and data.colors['tempNeedle'] or Color( data.colors['tempNeedle'].r / 3, data.colors['tempNeedle'].g / 3, data.colors['tempNeedle'].b / 3, 210 )
                        end
                    }
                }
            },
            {
                type = 'Cluster',
                name = 'Fuel',
                data = {
                    value = function()
                        return data.rpm == 0 and 0 or (GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and (data.nitrousenabled and 100 * data.nitrous or 100) or data.fuelLerp)
                    end,
                    --name = fuel,
                    max = 1
                },
                renderData = {
                    position = {
                        x = 0.012,
                        y = 0.07
                    },
                    additional = {
                        [1] = {
                            mat = UVMaterials["TACHO2_NR_SMALL_BACKING_GLASS"],
                            scale = 0.28,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['backingGlass']
                            end
                        },
                        [2] = {
                            mat = UVMaterials["TACHO2_NR_SMALL_BACKING"],
                            scale = 0.28,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = color_black
                        },
                        [3] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.18,
                            offsets = {
                                x = 0.005,
                                y = 0
                            },
                            color = function() 
                                return Color(data.colors['fuelNeedle'].r, data.colors['fuelNeedle'].g, data.colors['fuelNeedle'].b, data.rpm == 0 and 0 or 63)
                            end
                        },
                        [4] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLASS"],
                            scale = 0.04,
                            offsets = {
                                x = 0.005,
                                y = 0
                            },
                            color = function() 
                                return data.colors['switchedOffLight']
                            end
                        },
                        [5] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.04,
                            offsets = {
                                x = -0.015,
                                y = 0
                            },
                            color = function() 
                                return data.rpm ~= 0 and not GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and data.fuelLerp <= 0.2 and Color(255,0,0,75) or Color(0,0,0,0)
                            end
                        },
                        [6] = {
                            mat = UVMaterials["SHARED_DASH_NR_LIGHT"],
                            scale = 0.014,
                            offsets = {
                                x = -0.015,
                                y = 0
                            },
                            color = function() 
                                return data.rpm ~= 0 and not GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and data.fuelLerp <= 0.2 and Color(255,0,0,150) or Color(0,0,0,0)
                            end
                        },
                    },
                    needle = {
                        animation = {
                            idle = 50,
    	                    max = 145,
    	                    direction = -1,
                            velocity = 3
                        },
                        scale = 0.3,
                        offsets = {
                            x = 0.005,
                            y = 0
                        },
                        mat = UVMaterials["TACHO2_NR_SMALL_NEEDLE"],
                        color = function() 
                            return data.rpm ~= 0 and data.colors['fuelNeedle'] or Color( data.colors['fuelNeedle'].r / 3, data.colors['fuelNeedle'].g / 3, data.colors['fuelNeedle'].b / 3, 210 )
                        end
                    },
                    gauge = {
                        mat = UVMaterials["TACHO2_NR_FUEL_GAUGE"],
                        scale = 0.3,
                        offsets = {
                            x = 0,
                            y = 0
                        },
                        color = function() 
                            return data.rpm ~= 0 and data.colors['fuelGauge'] or data.colors['switchedOffLight']
                        end
                    }
                }
            },
            {
                type = 'Gears',
                data = {
                    value = function()
                        return data.gear
                    end,
                },
                renderData = {
                    position = {
                        x = -0.122,
                        y = 0.066
                    },
                    additional = {},
                    gears = {
                        font = "UVNightRunnersLCDFont-Tiny1",
                        textAlign = TEXT_ALIGN_RIGHT,
                        textColor = function()
                            return data.colors['mainGauge']
                        end,
                        offsets = {
                            x = 0.005,
                            y = 0
                        },
                        icon = {
                            upMat = UVMaterials["SHARED_DASH_NR_SHIFT_UP_ICON"],
                            upColor = function()
                                return data.colors['mainGauge']
                            end,
                            downMat = UVMaterials["SHARED_DASH_NR_SHIFT_DOWN_ICON"],
                            downColor = function()
                                return data.colors['mainGauge']
                            end,
                            offsets = {
                                x = -0.011,
                                y = 0.02
                            },
                            scale = 0.02,
                            color = function()
                                return data.colors['mainGauge']
                            end
                        }
                    }
                }
            },
            {
                type = 'Odometer',
                data = {
                    value = function()
                        return Glide.currentVehicle.__ODO
                    end,
                },
                renderData = {
                    position = {
                        x = -0.087,
                        y = 0.028
                    },
                    additional = {
                        [1] = {
                            mat = UVMaterials["SHARED_DASH_NR_ODOMETER"],
                            scale = 0.2,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            sizeOffsets = {
                                x = 0.02,
                                y = 0
                            },
                            color = function()
                                return data.rpm == 0 and data.colors['switchedOffLight'] or color_white
                            end
                        }
                    },
                    display = {
                        unit = {
                            text = "KM",
                            offset = {
                                x = -0.0238,
                                y = 0.0565
                            },
                            font = "UVNightRunnersLCDFont-ODOMETERUNIT2",
                            color = function()
                                return color_black
                            end,
                            align = TEXT_ALIGN_LEFT,
                            outlineWidth = 0.5,
                            outlineColor = function()
                                return color_black
                            end,
                        },
                        value = {
                            text = function()
                                return string.Comma(math.floor(Glide.currentVehicle.__ODO), "'")
                            end,
                            offset = {
                                x = 0.025,
                                y = 0.049
                            },
                            font = "UVNightRunnersLCDFont-ODOMETERVALUE2",
                            color = function()
                                return color_black
                            end,
                            align = TEXT_ALIGN_RIGHT,
                            outlineWidth = 0.5,
                            outlineColor = function()
                                return color_black
                            end,
                        }
                    }
                }
            }
        },
        [3] = {
            {
                type = 'Cluster',
                name = 'RPM',
                data = {
                    value = function()
                        return data.rpm
                    end,
                    --name = 'rpm',
                    max = function() 
                        return data.maxrpm
                    end
                },
                renderData = {
                    position = {
                        x = -0.025,
                        y = -0.2
                    },
                    additional = {
                        [1] = {
                            mat = UVMaterials["TACHO2_NR_BIG_BACKING_GLASS"],
                            scale = 0.32,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['backingGlass']
                            end
                        },
                        [2] = {
                            mat = UVMaterials["TACHO2_NR_BIG_BACKING"],
                            scale = 0.32,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = color_black
                        },
                        [3] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.2,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.rpm ~= 0 and data.colors['mainNeedle'] or Color( 0, 0, 0, 0 )
                            end
                        },
                        [4] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLASS"],
                            scale = 0.05,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['switchedOffLight']
                            end
                        },
                        [5] = {
                            mat = UVMaterials["SHARED_DASH_NR_ENGINE_OVERHEAT"],
                            scale = 0.023,
                            offsets = {
                                x = 0.02,
                                y = 0.05
                            },
                            color = function() 
                                return data.rpm ~= 0 and not GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and data.tempLerp >= 0.91 and Color(255,0,0,255) or Color(0,0,0,0)
                            end
                        },
                    },
                    needle = {
                        animation = {
                            idle = 90,
                            max = 360,
                            direction = -1,
                            velocity = 8
                        },
                        scale = 0.32,
                        offsets = {
                            x = 0,
                            y = 0.0001
                        },
                        sizeOffsets = {
                            x = 0.017,
                            y = 0
                        },
                        lowWobble = {
                            min = 0.05,
                            max = 0.2,
                            intensity = 2
                        },
                        redlining = {
                            intensity = 4
                        },
                        mat = UVMaterials["TACHO3_NR_BIG_NEEDLE"],
                        color = function() 
                            return data.rpm ~= 0 and data.colors['mainNeedle'] or Color( data.colors['mainNeedle'].r / 3, data.colors['mainNeedle'].g / 3, data.colors['mainNeedle'].b / 3, 210 )
                        end
                    },
                    gauge = {
                        mat = UVMaterials["TACHO3_NR_RPM_GAUGE"],
                        scale = 0.32,
                        -- redline = {
                        --     mat = UVMaterials["TACHO2_NR_REDLINE"],
                        --     scale = 0.32,
                        --     offsets = {
                        --         x = 0,
                        --         y = 0
                        --     },
                        --     color = function() 
                        --         return data.rpm ~= 0 and data.colors['redline'] or Color( data.colors['redline'].r / 3, data.colors['redline'].g / 3, data.colors['redline'].b / 3, 210 )
                        --     end
                        -- },
                        offsets = {
                            x = 0,
                            y = 0
                        },
                        color = function() 
                            return data.rpm ~= 0 and data.colors['mainGauge'] or data.colors['switchedOffLight']
                        end
                    }
                }
            },
            {
                type = 'Cluster',
                name = 'Speedo',
                data = {
                    value = function()
                        return data.speed
                    end,
                    --name = 'speed',
                    max = 460
                },
                renderData = {
                    position = {
                        x = -0.1,
                        y = 0.01
                    },
                    additional = {
                        [1] = {
                            mat = UVMaterials["TACHO2_NR_BIG_BACKING_GLASS"],
                            scale = 0.32,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['backingGlass']
                            end
                        }, 
                        [2] = {
                            mat = UVMaterials["TACHO2_NR_BIG_BACKING"],
                            scale = 0.32,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = color_black
                        },
                        [3] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.2,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.rpm ~= 0 and data.colors['mainNeedle'] or Color( 0, 0, 0, 0 )
                            end
                        },
                        [4] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLASS"],
                            scale = 0.05,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['switchedOffLight']
                            end
                        },
                    },
                    needle = {
                        animation = {
                            idle = 45,
                            max = 270,
                            direction = -1,
                            velocity = 8
                        },
                        scale = 0.32,
                        offsets = {
                            x = 0,
                            y = -0.0005
                        },
                        sizeOffsets = {
                            x = 0.017,
                            y = 0.017
                        },
                        mat = UVMaterials["TACHO3_NR_BIG_NEEDLE"],
                        color = function() 
                            return data.rpm ~= 0 and data.colors['mainNeedle'] or Color( data.colors['mainNeedle'].r / 3, data.colors['mainNeedle'].g / 3, data.colors['mainNeedle'].b / 3, 210 )
                        end
                    },
                    gauge = {
                        mat = UVMaterials["TACHO3_NR_SPEEDO_GAUGE"],
                        scale = 0.32,
                        offsets = {
                            x = 0,
                            y = 0
                        },
                        color = function() 
                            return data.rpm ~= 0 and data.colors['mainGauge'] or data.colors['switchedOffLight']
                        end
                    },
                }
            },
            {
                type = 'Cluster',
                name = 'Temperature',
                data = {
                    value = function()
                        return data.rpm == 0 and 0 or (GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and (data.speedbreakerenabled and data.maxtemp * data.speedbreaker or data.maxtemp) or data.tempLerp)
                    end,
                    --name = speed,
                    max = function()
                        return 1
                    end
                },
                renderData = {
                    position = {
                        x = 0.009,
                        y = 0.08
                    },
                    additional = {
                        [1] = {
                            mat = UVMaterials["TACHO1_NR_TEMP_GAUGE_GLASS"],
                            scale = 0.28,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['backingGlass']
                            end
                        },
                        [2] = {
                            mat = UVMaterials["TACHO1_NR_TEMP_GAUGE_BACKING"],
                            scale = 0.28,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = color_black
                        },
                        [3] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.18,
                            offsets = {
                                x = 0.018,
                                y = 0.027
                            },
                            color = function() 
                                return Color(data.colors['tempNeedle'].r, data.colors['tempNeedle'].g, data.colors['tempNeedle'].b, data.rpm == 0 and 0 or 63)
                            end
                        },
                        [4] = {
                            mat = UVMaterials["TACHO1_NR_SMALL_NEEDLE_GLASS"],
                            scale = 0.25,
                            offsets = {
                                x = 0.018,
                                y = 0.027
                            },
                            color = function() 
                                return data.colors['switchedOffLight']
                            end
                        },
                        [5] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.1,
                            offsets = {
                                x = -0.006,
                                y = 0.014
                            },
                            color = function() 
                                return data.rpm ~= 0 and not GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and data.tempLerp >= 0.91 and Color(255,0,0,75) or Color(0,0,0,0)
                            end
                        },
                        [6] = {
                            mat = UVMaterials["SHARED_DASH_NR_LIGHT"],
                            scale = 0.014,
                            offsets = {
                                x = -0.006,
                                y = 0.014
                            },
                            color = function() 
                                return data.rpm ~= 0 and not GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and data.tempLerp >= 0.91 and Color(255,0,0,150) or Color(0,0,0,0)
                            end
                        },

                    },
                    gauge = {
                        mat = UVMaterials["TACHO1_NR_TEMP_GAUGE"],
                        scale = 0.28,
                        offsets = {
                            x = 0,
                            y = 0
                        },
                        color = function() 
                            return data.rpm ~= 0 and data.colors['tempGauge'] or data.colors['switchedOffLight']
                        end
                    },
                    needle = {
                        animation = {
                            idle = 7,
                            max = 75,
                            direction = -1,
                            velocity = function() 
                                return 3
                            end
                        },
                        scale = 0.21,
                        offsets = {
                            x = 0.018,
                            y = 0.027
                        },
                        mat = UVMaterials["TACHO1_NR_SMALL_NEEDLE"],
                        color = function() 
                            return data.rpm ~= 0 and data.colors['tempNeedle'] or Color( data.colors['tempNeedle'].r / 3, data.colors['tempNeedle'].g / 3, data.colors['tempNeedle'].b / 3, 210 )
                        end
                    }
                }
            },
            {
                type = 'Cluster',
                name = 'Fuel',
                data = {
                    value = function()
                        return data.rpm == 0 and 0 or (GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and (data.nitrousenabled and 100 * data.nitrous or 100) or data.fuelLerp)
                    end,
                    --name = fuel,
                    max = 1
                },
                renderData = {
                    position = {
                        x = 0.03,
                        y = -0.03
                    },
                    additional = {
                        [1] = {
                            mat = UVMaterials["TACHO1_NR_FUEL_GAUGE_GLASS"],
                            scale = 0.28,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = function() 
                                return data.colors['backingGlass']
                            end
                        },
                        [2] = {
                            mat = UVMaterials["TACHO1_NR_FUEL_GAUGE_BACKING"],
                            scale = 0.28,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            color = color_black
                        },
                        [3] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.18,
                            offsets = {
                                x = -0.02,
                                y = 0.029
                            },
                            color = function() 
                                return Color(data.colors['fuelNeedle'].r, data.colors['fuelNeedle'].g, data.colors['fuelNeedle'].b, data.rpm == 0 and 0 or 63)
                            end
                        },
                        [4] = {
                            mat = UVMaterials["TACHO1_NR_SMALL_NEEDLE_GLASS"],
                            scale = 0.25,
                            offsets = {
                                x = -0.02,
                                y = 0.029
                            },
                            color = function() 
                                return data.colors['switchedOffLight']
                            end
                        },
                        [5] = {
                            mat = UVMaterials["SHARED_DASH_NR_NEEDLE_GLOW"],
                            scale = 0.1,
                            offsets = {
                                x = 0.003,
                                y = 0.019
                            },
                            color = function() 
                                return data.rpm ~= 0 and not GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and data.fuelLerp <= 0.2 and Color(255,0,0,75) or Color(0,0,0,0)
                            end
                        },
                        [6] = {
                            mat = UVMaterials["SHARED_DASH_NR_LIGHT"],
                            scale = 0.014,
                            offsets = {
                                x = 0.003,
                                y = 0.019
                            },
                            color = function() 
                                return data.rpm ~= 0 and not GetConVar("uvspeedo_nightrunners_shownitrous"):GetBool() and data.fuelLerp <= 0.2 and Color(255,0,0,150) or Color(0,0,0,0)
                            end
                        },
                    },
                    needle = {
                        animation = {
                            idle = -189,
    	                    max = -255,
    	                    direction = -1,
                            velocity = 3
                        },
                        scale = 0.21,
                        offsets = {
                            x = -0.02,
                            y = 0.029
                        },
                        mat = UVMaterials["TACHO1_NR_SMALL_NEEDLE"],
                        color = function() 
                            return data.rpm ~= 0 and data.colors['fuelNeedle'] or Color( data.colors['fuelNeedle'].r / 3, data.colors['fuelNeedle'].g / 3, data.colors['fuelNeedle'].b / 3, 210 )
                        end
                    },
                    gauge = {
                        mat = UVMaterials["TACHO1_NR_FUEL_GAUGE"],
                        scale = 0.28,
                        offsets = {
                            x = 0,
                            y = 0
                        },
                        color = function() 
                            return data.rpm ~= 0 and data.colors['fuelGauge'] or data.colors['switchedOffLight']
                        end
                    }
                }
            },
            {
                type = 'Gears',
                data = {
                    value = function()
                        return data.gear
                    end,
                },
                renderData = {
                    position = {
                        x = -0.061,
                        y = 0.033
                    },
                    additional = {},
                    gears = {
                        font = "UVNightRunnersLCDFont-Tiny1",
                        textAlign = TEXT_ALIGN_RIGHT,
                        textColor = function()
                            return data.colors['mainGauge']
                        end,
                        offsets = {
                            x = 0.005,
                            y = 0
                        },
                        icon = {
                            upMat = UVMaterials["SHARED_DASH_NR_SHIFT_UP_ICON"],
                            upColor = function()
                                return data.colors['mainGauge']
                            end,
                            downMat = UVMaterials["SHARED_DASH_NR_SHIFT_DOWN_ICON"],
                            downColor = function()
                                return data.colors['mainGauge']
                            end,
                            offsets = {
                                x = -0.011,
                                y = 0.02
                            },
                            scale = 0.02,
                            color = function()
                                return data.colors['mainGauge']
                            end
                        }
                    }
                }
            },
            {
                type = 'Odometer',
                data = {
                    value = function()
                        return Glide.currentVehicle.__ODO
                    end,
                },
                renderData = {
                    position = {
                        x = -0.101,
                        y = 0.029
                    },
                    additional = {
                        [1] = {
                            mat = UVMaterials["SHARED_DASH_NR_ODOMETER"],
                            scale = 0.2,
                            offsets = {
                                x = 0,
                                y = 0
                            },
                            sizeOffsets = {
                                x = 0.02,
                                y = 0
                            },
                            color = function()
                                return data.rpm == 0 and data.colors['switchedOffLight'] or color_white
                            end
                        }
                    },
                    display = {
                        unit = {
                            text = "KM",
                            offset = {
                                x = -0.0238,
                                y = 0.0565
                            },
                            font = "UVNightRunnersLCDFont-ODOMETERUNIT2",
                            color = function()
                                return color_black
                            end,
                            align = TEXT_ALIGN_LEFT,
                            outlineWidth = 0.5,
                            outlineColor = function()
                                return color_black
                            end,
                        },
                        value = {
                            text = function()
                                return string.Comma(math.floor(Glide.currentVehicle.__ODO), "'")
                            end,
                            offset = {
                                x = 0.025,
                                y = 0.049
                            },
                            font = "UVNightRunnersLCDFont-ODOMETERVALUE2",
                            color = function()
                                return color_black
                            end,
                            align = TEXT_ALIGN_RIGHT,
                            outlineWidth = 0.5,
                            outlineColor = function()
                                return color_black
                            end,
                        }
                    }
                }
            }
        },

    }
}

local function _get( value )
    return type(value) == 'function' and value() or value
end

local function RenderUI()
    local style = GetConVar("uvspeedo_nightrunners_gauge"):GetInt()
    local styleData = UV_UI.speedometer.nightrunners.settings.styles[style]
    if not styleData then return end
    
    UV_UI.speedometer.nightrunners.states.elements[style] = UV_UI.speedometer.nightrunners.states.elements[style] or {}
    local styleElements = UV_UI.speedometer.nightrunners.states.elements[style]
    
    for elementId, element in ipairs(styleData) do
        styleElements[elementId] = styleElements[elementId] or {}
        if element.func then element.func() end
        if not element.renderData then continue end

        local posX = element.renderData.position and data.posX + ( data.screenX * _get( element.renderData.position.x ) ) or data.posX
        local posY = element.renderData.position and data.posY + ( data.screenY * _get( element.renderData.position.y ) ) or data.posY
        
        for additionalId, additional in ipairs(element.renderData.additional) do
            local args = {}
            if additional.sizeOffsets then
                args.sizeOffsets = additional.sizeOffsets
            end
            DrawIcon(
            additional.mat, 
            posX + ( data.screenX * _get( additional.offsets.x ) ), 
            posY + ( data.screenY * _get( additional.offsets.y ) ), 
            _get( additional.scale ) or 1, 
            _get( additional.color ),
            args )
        end

        if element.type == 'Cluster' then

            if element.renderData.gauge then
                DrawIcon(
                element.renderData.gauge.mat,
                posX + ( data.screenX * _get( element.renderData.gauge.offsets.x ) ),
                posY + ( data.screenY * _get( element.renderData.gauge.offsets.y ) ),
                _get( element.renderData.gauge.scale ) or 1,
                _get( element.renderData.gauge.color ) )

                if element.renderData.gauge.redline then
                    DrawIcon(
                    element.renderData.gauge.redline.mat,
                    posX + ( data.screenX * _get( element.renderData.gauge.redline.offsets.x ) ),
                    posY + ( data.screenY * _get( element.renderData.gauge.redline.offsets.y ) ),
                    _get( element.renderData.gauge.redline.scale ) or 1,
                    _get( element.renderData.gauge.redline.color ) )
                end
            end
            if element.renderData.needle then
                local inputValue = _get( element.data.value ) or 0
                local maxInputValue = _get( element.data.max )

                local _rawValue, outputValue = CalcLerp( styleElements[elementId].__outputValue or inputValue, inputValue, maxInputValue, _get( element.renderData.needle.animation.velocity ) )
                styleElements[elementId].__outputValue = _rawValue

                local needleAngle = _get( element.renderData.needle.animation.idle ) + _get( element.renderData.needle.animation.direction ) * (outputValue * (_get( element.renderData.needle.animation.max ) - _get( element.renderData.needle.animation.idle ) ))
                local needleScale = math.min(data.screenX, data.screenY) * (_get( element.renderData.needle.scale ) or 1)

                if element.renderData.needle.lowWobble then
                    if outputValue > _get( element.renderData.needle.lowWobble.min ) and outputValue <= _get( element.renderData.needle.lowWobble.max ) then
                        local t = RealTime() * 10
                        local lowWobble = math.random( -0.7, 0.7 ) * _get( element.renderData.needle.lowWobble.intensity ) * ( 1 - outputValue / 0.2 )
                        needleAngle = needleAngle + lowWobble
                    end
                end

                if element.renderData.needle.redlining and data.redlining then
                    needleAngle = needleAngle + math.abs( math.Clamp( math.cos( RealTime() * data.redlinestrength ), 0, 1 ) * _get( element.renderData.needle.redlining.intensity ) )
                end
                
                local needleSizeX, needleSizeY = needleScale, needleScale

                if element.renderData.needle.sizeOffsets then
                    needleSizeX = needleSizeX + ( data.screenX * _get( element.renderData.needle.sizeOffsets.x ) or 0)
                    needleSizeY = needleSizeY + ( data.screenY * _get( element.renderData.needle.sizeOffsets.y ) or 0)
                end

                surface.SetMaterial(element.renderData.needle.mat)
                surface.SetDrawColor(_get( element.renderData.needle.color ))
                surface.DrawTexturedRectRotated(
                posX + ( data.screenX * _get( element.renderData.needle.offsets.x ) ),
                posY + ( data.screenY * _get( element.renderData.needle.offsets.y ) ),
                needleSizeX,
                needleSizeY,
                needleAngle )
            end
        elseif element.type == 'Gears' then
            if element.renderData.gears and data.rpm ~= 0 then
                if data.gear ~= UV_UI.speedometer.nightrunners.states.lastGear and element.renderData.gears.icon then
                    styleElements[elementId].__lastGearIcon = data.gear < UV_UI.speedometer.nightrunners.states.lastGear and _get( element.renderData.gears.icon.downMat ) or _get( element.renderData.gears.icon.upMat )
                    styleElements[elementId].__lastGearColor = data.gear < UV_UI.speedometer.nightrunners.states.lastGear and _get( element.renderData.gears.icon.downColor ) or _get( element.renderData.gears.icon.upColor )
                end

                draw.SimpleText( data.gearText, element.renderData.gears.font, posX + ( data.screenX * _get( element.renderData.gears.offsets.x ) ), posY + ( data.screenY * _get( element.renderData.gears.offsets.y ) ), _get( element.renderData.gears.textColor ), element.renderData.gears.textAlign )
                if not styleElements[elementId].__lastGearIcon then continue end

                DrawIcon(styleElements[elementId].__lastGearIcon, posX + ( data.screenX * _get( element.renderData.gears.icon.offsets.x ) ), posY + ( data.screenY * _get( element.renderData.gears.icon.offsets.y ) ), _get( element.renderData.gears.icon.scale ) or 1, _get( styleElements[elementId].__lastGearColor ))

                styleElements[elementId].__lastGearColor = styleElements[elementId].__lastGearColor:Lerp(color_black, FrameTime() * (CurTime() - UV_UI.speedometer.nightrunners.states.lastGearSwitch < 1 and .2 or 3))
            end
        elseif element.type == 'Odometer' then
            if element.renderData.display and data.rpm ~= 0 then
                if element.renderData.display.unit then
                    draw.SimpleTextOutlined( 
                    _get( element.renderData.display.unit.text ), 
                    _get( element.renderData.display.unit.font ), 
                    posX + ( data.screenX * _get( element.renderData.display.unit.offset.x ) ), 
                    posY + ( data.screenY * _get( element.renderData.display.unit.offset.y ) ), 
                    _get( element.renderData.display.unit.color ), 
                    _get( element.renderData.display.unit.align ), 
                    nil, 
                    _get( element.renderData.display.unit.outlineWidth ), 
                    _get( element.renderData.display.unit.outlineColor ) )
                end
                if element.renderData.display.value and data.rpm ~= 0 then
                    draw.SimpleTextOutlined( 
                    _get( element.renderData.display.value.text ), 
                    _get( element.renderData.display.value.font ), 
                    posX + ( data.screenX * _get( element.renderData.display.value.offset.x ) ), 
                    posY + ( data.screenY * _get( element.renderData.display.value.offset.y ) ), 
                    _get( element.renderData.display.value.color ), 
                    _get( element.renderData.display.value.align ), 
                    nil, _get( element.renderData.display.value.outlineWidth ), _get( element.renderData.display.value.outlineColor ) )
                end
            end
        end
    end
end

local function nightrunners_speedometer( ... )
    local w = ScrW()
    local h = ScrH()
    
    local speed = select(1, ...)
    local speedname = select(2, ...)
    local gear = select(3, ...)
    local rpm = select(4, ...)
    local maxrpm = select(5, ...)
    local throttle = select(6, ...)
    local redlining = select(7, ...)
    local redlinestrength = select(8, ...)
    local health = select(9, ...)
    local nitrousenabled = select(10, ...)
    local nitrous = select(11, ...)
    local speedbreakerenabled = select(12, ...)
    local speedbreaker = select(13, ...)
    local kmh = select(14, ...)
    local mph = select(15, ...)
    
    local gearText = tostring(gear)
    if gear == -1 then gearText = "R"
    elseif gear == 0 then gearText = "N" end
    
    data.posX = w * (GetConVar("uvspeedo_nightrunners_x"):GetFloat())
    data.posY = h * (GetConVar("uvspeedo_nightrunners_y"):GetFloat())

    local screenXBase = math.min( w, h * ( UV.BaseW / UV.BaseH ) )
    local targetAspect = UV.BaseW / UV.BaseH
    local currentAspect = w / h
    local narrowAspectFactor = math.Clamp( ( targetAspect - currentAspect ) / targetAspect, 0, 1 )
    local spacingCompensation = 1 + narrowAspectFactor

    data.screenX = screenXBase * spacingCompensation
    data.screenY = h
    data.speed = speed
    data.speedname = speedname
    data.gear = gear
    data.gearText = gearText
    data.rpm = rpm
    data.maxrpm = maxrpm
    data.throttle = throttle
    data.redlining = redlining
    data.redlinestrength = redlinestrength
    data.health = health
    data.nitrousenabled = nitrousenabled
    data.nitrous = nitrous
    data.speedbreakerenabled = speedbreakerenabled
    data.speedbreaker = speedbreaker
    data.kmh = kmh
    data.mph = mph
    
    local speedopos = {
        x = w * (GetConVar("uvspeedo_nightrunners_x"):GetFloat()),
        y = h * (GetConVar("uvspeedo_nightrunners_y"):GetFloat()),
    }
    
    local colorValues = {
        maingauges = {
            r = GetConVar("uvspeedo_nightrunners_col_maingauges_r"):GetInt(),
            g = GetConVar("uvspeedo_nightrunners_col_maingauges_g"):GetInt(),
            b = GetConVar("uvspeedo_nightrunners_col_maingauges_b"):GetInt(),
        },
        mainneedles = {
            r = GetConVar("uvspeedo_nightrunners_col_mainneedles_r"):GetInt(),
            g = GetConVar("uvspeedo_nightrunners_col_mainneedles_g"):GetInt(),
            b = GetConVar("uvspeedo_nightrunners_col_mainneedles_b"):GetInt(),
        },
        tempgauges = {
            r = GetConVar("uvspeedo_nightrunners_col_tempgauges_r"):GetInt(),
            g = GetConVar("uvspeedo_nightrunners_col_tempgauges_g"):GetInt(),
            b = GetConVar("uvspeedo_nightrunners_col_tempgauges_b"):GetInt(),
        },
        fuelgauges = {
            r = GetConVar("uvspeedo_nightrunners_col_fuelgauges_r"):GetInt(),
            g = GetConVar("uvspeedo_nightrunners_col_fuelgauges_g"):GetInt(),
            b = GetConVar("uvspeedo_nightrunners_col_fuelgauges_b"):GetInt(),
        },
        tempneedles = {
            r = GetConVar("uvspeedo_nightrunners_col_tempneedles_r"):GetInt(),
            g = GetConVar("uvspeedo_nightrunners_col_tempneedles_g"):GetInt(),
            b = GetConVar("uvspeedo_nightrunners_col_tempneedles_b"):GetInt(),
        },
        fuelneedles = {
            r = GetConVar("uvspeedo_nightrunners_col_fuelneedles_r"):GetInt(),
            g = GetConVar("uvspeedo_nightrunners_col_fuelneedles_g"):GetInt(),
            b = GetConVar("uvspeedo_nightrunners_col_fuelneedles_b"):GetInt(),
        },
        redline = {
            r = GetConVar("uvspeedo_nightrunners_col_redline_r"):GetInt(),
            g = GetConVar("uvspeedo_nightrunners_col_redline_g"):GetInt(),
            b = GetConVar("uvspeedo_nightrunners_col_redline_b"):GetInt(),
        },
    }
    
    local sideGaugeSecFunc = GetConVar( 'uvspeedo_nightrunners_shownitrous' )
    
    local switchedOffLightColor = Color( 93, 93, 93 )
    local backingGlass = Color( 0, 0, 0, 212)
    local mainNeedleColor = Color( colorValues.mainneedles.r, colorValues.mainneedles.g, colorValues.mainneedles.b )
    local mainGaugeColor = Color( colorValues.maingauges.r, colorValues.maingauges.g, colorValues.maingauges.b )
    local redlineColor = Color( colorValues.redline.r, colorValues.redline.g, colorValues.redline.b )
    local tempGaugeColor = Color( colorValues.tempgauges.r, colorValues.tempgauges.g, colorValues.tempgauges.b )
    local fuelGaugeColor = Color( colorValues.fuelgauges.r, colorValues.fuelgauges.g, colorValues.fuelgauges.b )
    local tempNeedleColor = Color( colorValues.tempneedles.r, colorValues.tempneedles.g, colorValues.tempneedles.b )
    local fuelNeedleColor = Color( colorValues.fuelneedles.r, colorValues.fuelneedles.g, colorValues.fuelneedles.b )
    
    data.colors.switchedOffLight = switchedOffLightColor
    data.colors.backingGlass = backingGlass
    data.colors.mainNeedle = mainNeedleColor
    data.colors.mainGauge = mainGaugeColor
    data.colors.redline = redlineColor
    data.colors.tempGauge = tempGaugeColor
    data.colors.fuelGauge = fuelGaugeColor
    data.colors.tempNeedle = tempNeedleColor
    data.colors.fuelNeedle = fuelNeedleColor
    
    if rpm == 0 then UV_UI.speedometer.nightrunners.states.lastSwitchOff = CurTime() end

    if gear ~= UV_UI.speedometer.nightrunners.states.lastGear then
        UV_UI.speedometer.nightrunners.states.lastGearSwitch = CurTime()
    end

    Glide.currentVehicle.__ODO = Glide.currentVehicle.__ODO or math.random(0, 999999)
    local dt = RealFrameTime()
    
    local speedInKmh = kmh
    local kmTraveled = speedInKmh * (dt / 3600)
    Glide.currentVehicle.__ODO = math.Clamp(math.max(0, (tonumber(Glide.currentVehicle.__ODO) or 0) + kmTraveled), 0, 999999)
    speed = speedInKmh

    -- temp
    if Glide.currentVehicle ~= UV_UI.speedometer.nightrunners.states.lastVehicle then
        UV_UI.speedometer.nightrunners.states.lastVehicle = Glide.currentVehicle
        UV_UI.speedometer.nightrunners.states.temp_lerp = 0
    end

    local temp = rpm == 0 and 0 or math.Remap(speed, 0, 320, .3, 1)
    UV_UI.speedometer.nightrunners.states.temp_lerp = Lerp(FrameTime() * 0.2, UV_UI.speedometer.nightrunners.states.temp_lerp or temp, temp)
    data.maxtemp = 1
    data.temp = temp
    data.tempLerp = UV_UI.speedometer.nightrunners.states.temp_lerp

    -- fuel\

    local fuel = math.Clamp(health, 0, 1)
    data.fuel = fuel
    UV_UI.speedometer.nightrunners.states.fuel_lerp = Lerp(FrameTime() * 3, UV_UI.speedometer.nightrunners.states.fuel_lerp or fuel, fuel)
    data.fuelLerp = UV_UI.speedometer.nightrunners.states.fuel_lerp

    RenderUI()
    
    UV_UI.speedometer.nightrunners.states.lastGear = gear
end

UV_UI.speedometer.nightrunners.main = nightrunners_speedometer
UV_UI.speedometer.nightrunners.states = {
    lastSwitchOff = 0,
    lastGear = 0,
    lastGearSwitch = 0,
    elements = {},
    lastGearIcon = nil,
    lastVehicle = Glide.currentVehicle,
    lastColor = Color(38, 225, 0),
    rpm_lerp = 0,
}

UV_UI.speedometer.nightrunners.offsets = { x = 0.1025, y = 0.4 }