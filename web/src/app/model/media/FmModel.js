/**
 * @name MFT.FmData
 * 
 * @desc FM Media data model
 * 
 * @category	Model
 * @filesource	app/model/media/FmData.js
 * @version		2.0
 *
 * @author		Igor Zhavoronkin
 */
MFT.FmModel = Em.Object.create({

    init: function () {
        var i,
            index,
            station,
            directTunes = [],
            directTuneItems = {};

        this._super();

        for (i = 87.9; i <= 107.9; i+=0.05) {
            station = i.toFixed(2);
            index = station.replace('.','');

            directTuneItems[index] = MFT.PlaylistItem.create({frequency: station});

            directTunes.push(index.split(''));
        }

        this.directTunestations.set('directTunes', directTunes);
        this.directTunestations.set('directTuneItems', directTuneItems);
    },
	
	band: MFT.RangedValue.create({value:-1, activeBand:0}),
	
	directTunestations: MFT.Playlist.create({
		
			/** Direct tune dial station matrix */
			directTunes: [],
			
			/** Direct tune Data */
			directTuneItems: {}
	
	}),
	
	fm1: MFT.Playlist.create( {
		selectedIndex: 					1,

		items: {
			0:MFT.PlaylistItem.create({frequency: '87.90',genre: 'Pop',title: 'BlUE SKY',artist: 'THE MAX', isHd: false}) ,
			1:MFT.PlaylistItem.create({frequency: '90.90',genre: 'Club',title: 'JUMP AND DOWN',artist: 'THE PROJECT X', isHd: false}),
			2:MFT.PlaylistItem.create({frequency: '105.10',genre: 'Rock',title: 'WELCOME HOME',artist: 'TODD SULLIVAN',isHd: false}),
			3:MFT.PlaylistItem.create({frequency: '98.50',genre: 'Pop',title: 'LETS DANCE',artist: 'MICHAEL JOHNSON',isHd: false}),
			4:MFT.PlaylistItem.create({frequency: '106.30',genre: 'Pop Rock',title: 'YESTERDAY NIGHT',artist: 'JOHN SMITH', isHd: false}),
			5:MFT.PlaylistItem.create({frequency: '107.90',genre: 'Classic',title: 'TENTH SYMPHONY',artist: 'SPENCER M.', isHd: false})
		}
	}),
	
	fm2: MFT.Playlist.create( {
		selectedIndex: 					4,

        items:{
			0:MFT.PlaylistItem.create({frequency: '101.10',genre: 'Club',title: 'SPRING TIME',artist: 'DJ SKY', isHd: false}) ,
			1:MFT.PlaylistItem.create({frequency: '103.20',genre: 'Rock',title: 'RAINBOW',artist: 'THE BEES', isHd: false}),
			2:MFT.PlaylistItem.create({frequency: '99.30',genreBinding: 'MFT.locale.label.view_media_genre_classic',title: 'SUNSET',artist: 'SKYLARK',isHd: MFT.SettingsModel.isEnglish, HDChannels: 3, currentHDChannel: 2}),
			3:MFT.PlaylistItem.create({frequency: '103.50',genre: 'Club',title: 'JUMP AND DOWN',artist: 'THE PROJECT X',isHd: MFT.SettingsModel.isEnglish, HDChannels: 3, currentHDChannel: 3}),
			4:MFT.PlaylistItem.create({frequency: '104.10',genre: 'Pop',title: 'HONEY',artist: 'EPTON JOHN', isHd: false}),
			5:MFT.PlaylistItem.create({frequency: '105.20',genre: 'Pop',title: 'LETS DANCE',artist: 'MICHAEL JOHNSON', isHd: false})
		}
	}),
	
	fmAst: MFT.Playlist.create( {				
		selectedIndex: 					1,

        items:{
			0:MFT.PlaylistItem.create({frequency: '98.20',genre: 'Club',title: 'SPRING TIME',artist: 'DJ SKY', isHd: false}) ,
			1:MFT.PlaylistItem.create({frequency: '106.60',genre: 'Rock',title: 'WELCOME HOME',artist: 'TODD SULLIVAN', isHd: false}),
			2:MFT.PlaylistItem.create({frequency: '99.30',genre: 'Pop',title: 'GOOD MORNING',artist: 'SUSAN BAKER',isHd: MFT.SettingsModel.isEnglish, HDChannels: 2, currentHDChannel: 2}),
			3:MFT.PlaylistItem.create({frequency: '107.50',genreBinding: 'MFT.locale.label.view_media_genre_classic',title: 'SUNSET',artist: 'SKYLARK',isHd: MFT.SettingsModel.isEnglish, HDChannels: 3, currentHDChannel: 1}),
			4:MFT.PlaylistItem.create({frequency: '106.10',genre: 'Pop',title: 'HONEY',artist: 'EPTON JOHN', isHd: false}),
			5:MFT.PlaylistItem.create({frequency: '104.20',genreBinding: 'MFT.locale.label.view_media_genre_classic',title: 'TENTH SYMPHONY',artist: 'SPENCER M.', isHd: false})
		}

	})

});