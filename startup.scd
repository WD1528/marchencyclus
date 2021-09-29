(
// configure the sound server: here you could add hardware specific options
// see http://doc.sccode.org/Classes/ServerOptions.html
s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
s.options.memSize = 8192 * 64; // increase this if you get "alloc failed" messages
s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
s.options.numOutputBusChannels = 2; // set this to your hardware output channel size, if necessary
s.options.numInputBusChannels = 0; // set this to your hardware output channel size, if necessary
// boot the server and start SuperDirt

// Server.default.options.device_("Scarlett 2i4 USB");

s.waitForBoot {
	~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
	~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
	~dirt.loadSoundFiles("/users/wannes/Dirt/samples/*");
	// ~dirt.loadSoundFiles("/users/wannes/Dirt/pcu/*");
	~dirt.loadSoundFiles("/users/wannes/Dirt/mainsamples/*");
	~dirt.loadSoundFiles("/users/wannes/Dirt/hogobogo/*");
	~dirt.loadSoundFiles("/users/wannes/Dirt/set/*");
	~dirt.loadSoundFiles("/users/wannes/Dirt/v23/*");
	~dirt.loadSoundFiles("/users/wannes/Dirt/eSamplesdirt/*");
	~dirt.loadSoundFiles("/users/wannes/Dirt/recy/*");
	s.sync; // optionally: wait for samples to be read
	~dirt.start(57120, 0 ! 12);   // start listening on port 57120, create two busses each sending audio to channel 0


	// ServerOptions.outDevices; //output devices
	// Server.default.options.outDevice_("Built-in Output");
	// Server.default.options.device_("Scarlett 2i4 USB");
	Server.default.options.device_("Stream_Audio");


	// optional, needed for convenient access from sclang:
	(
		~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
		~d4 = ~dirt.orbits[3]; ~d5 = ~dirt.orbits[4]; ~d6 = ~dirt.orbits[5];
		~d7 = ~dirt.orbits[6]; ~d8 = ~dirt.orbits[7]; ~d9 = ~dirt.orbits[8];
		~d10 = ~dirt.orbits[9]; ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];
	);
};

s.latency = 0.4; // increase this if you get "late" messages

(
SynthDef.new("aa", {
	|out,sustain=1,freq=440,speed=1,begin=0,end=1,pan,accelerate,offset,modfreq=40,amp=0.3,size=1.0,rdec=1.0,satt=0.1,sdec=0.5,ssus=1|
	var line, env, volume, sum, temp;
	sum = 0;
	10.do{
		temp = SinOsc.ar(
			freq * {Rand(0.99,1.02)}!2,
			{Rand(0.0,0.2)}!2,
			0.1
		);
		sum = sum + temp;
	};
	line = Line.ar(0, 1, sustain, doneAction: 2);
	env = Env.new([0, 1, 0.9, 0], [satt, sdec, ssus], [-5, 0, 5]);
	volume = IEnvGen.ar(env, line);
	sum = sum * amp * volume;
	// sum = JPverb.ar(sum, t60: rdec, damp: line, size: size, earlyDiff: 0.202);
	OffsetOut.ar(out, DirtPan.ar(sum, ~dirt.numChannels, pan, volume));
}).add;


SynthDef.new("bb", {
	|out,sustain=1,freq=440,speed=1,begin=0,end=1,pan,accelerate,offset,modfreq=40,amp=1,satt=0.1,sdec=0.5,ssus=1,rdec=1.0,size=1.0|
	var line, env, volume, temp, sum;
	sum = 0;
	10.do{
		temp = LFSaw.ar(
			freq * {Rand(0.99,1.02)}!2,
			{Rand(0.0,0.2)}!2,
			0.1
		);
		sum = sum + temp;
	};
	line = Line.ar(begin, end, sustain, doneAction: 2);
	env = Env.new([0, 1, 0.9, 0], [satt, sdec, ssus], [-5, 0, 5]);
	volume = IEnvGen.ar(env, line);
	sum = sum * amp * volume;
	// sum = JPverb.ar(sum, t60: rdec, damp: line, size: size, earlyDiff: 0.202);
	OffsetOut.ar(out, DirtPan.ar(sum, ~dirt.numChannels, pan, volume));
}).add;


SynthDef.new("cc", {
	|out,sustain=1,freq=440,speed=1,begin=0,end=1,pan,accelerate,offset,modfreq=40,amp=1,satt=0.1,sdec=0.5,ssus=1,clamp=0.5,clampq=0.5|
	var line, env, volume, temp, sum;
	sum = 0;
	6.do{
		temp = BlitB3Saw.ar(
			freq,
			{Rand(0.5,0.9)}!2,
			0.2
		);
		sum = sum + temp;
	};
	line = Line.ar(begin, end, sustain, doneAction: 2);
	env = Env.new([0, 1, 0.9, 0], [satt, sdec, ssus], [-5, 0, 5]);
	volume = IEnvGen.ar(env, line);
	sum = sum * amp * volume;
	// sum = RLPF.ar(sum, 20000*clamp*volume, clampq);
	OffsetOut.ar(out, DirtPan.ar(sum, ~dirt.numChannels, pan, volume));
}).add;


SynthDef.new("dd", {
	|out,sustain=1,freq=440,speed=1,begin=0,end=1,pan,accelerate,offset,modfreq=40,amp=1,satt=0.1,sdec=0.5,ssus=1,clamp=0.5,clampq=0.5|
	var line, env, volume, sum, temp;
	sum = 0;
	10.do{
		temp = SinOsc.ar(
			freq*SinOsc.ar(freq*{Rand(9.5,10.5)}),
			mul: 0.3);
		temp = BBandPass.ar(temp, 10000+{Rand(-3000,3000)},{Rand(0.1,0.5)});
		sum = sum + temp;
	};
	line = Line.ar(begin, end, sustain, doneAction: 2);
	env = Env.new([0, 1, 0.9, 0], [satt, sdec, ssus], [(-5 * (satt * 10)), 0, 5]); // om att echt 0 te krijgen -5 * (satt * 10)
	volume = IEnvGen.ar(env, line);
	sum = sum * amp * volume;
	// sum = RLPF.ar(sum, 20000*clamp*volume, clampq);
	OffsetOut.ar(out, DirtPan.ar(sum, ~dirt.numChannels, pan, volume));
}).add;
));