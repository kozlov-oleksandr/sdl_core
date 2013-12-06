/*
 * @name ReverseSDL
 *
 *
 * @category	RPC component
 * @filesource	web/ReverseSDL.json
 * @version	1.0
 *
 * @author	Sergei Polishchuk
 *
 */
RevSDL = {
    methods: {
        /**
         * Sends a request for access to the management of head unit, through SDL interface
         **/
        GrantAccess: {
            response: {
                success: "boolean",
                resultCode: "string"
            }
        },

        /**
         * Sends a request for cancel access to the management of head unit, through SDL interface
         **/
        CancelAccess: {
            response: {
                success: "boolean",
                resultCode: "string"
            }
        },

        /**
         * Sends a request to change specified parameter for radio on head unit, through SDL interface
         **/
        TuneRadio: {
            parameters: {
                RadioStation: {
                    frequency: "int",
                    fraction: "int",
                    HD: "int"
                }
            }
        },

        /**
         * Start frequency scan on head unit, through SDL interface
         **/
        StartScan: {
            response: {
                success: "boolean",
                resultCode: "string"
            }
        },

        /**
         * Stop frequency scan on head unit, through SDL interface
         **/
        StopScan: {
            response: {
                success: "boolean",
                resultCode: "string"
            }
        },

        /** Sends a request show application on HMI, through SDL interface**/
        Show: {

        },

        /** Sends a TuneUp request, through SDL interface**/
        TuneUp: {
            response: {
                success: "boolean",
                resultCode: "string"
            }
        },

        /** Sends a TuneDown request, through SDL interface**/
        TuneDown: {
            response: {
                success: "boolean",
                resultCode: "string"
            }
        },

        /** Get saved presets from native mobile app **/
        GetNativeLocalPresets: {
            response: {
                customPresets: "array"
            }
        },

        /** Save presets to native mobile app**/
        SetNativeLocalPresets: {
            parameters: {
                customPresets: "array"
            }
        }
    },

    notifications: {
        OnControlChanged:{
            parameters:{
                /**
                 * SDL interrupt access status
                 * 1. 'DRIVER_FOCUS'
                 * 2. 'TIME_OUT'
                 */
                reason: "string"
            }
        },

        OnRadioDetails: {
            parameters: {
                radioStation: {
                    frequency: "int",
                    fraction: "int",
                    HD: "int"
                },
                songInfo: {
                    name: "string",
                    artist: "string",
                    genre: "string"
                }
            }
        },

        OnPresetsChanged: {
            parameters: {
                customPresets: "array"
            }
        }
    }
};