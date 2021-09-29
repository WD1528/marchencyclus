////////////////////////////////////////////////////
OSCdef.freeAll;
s.freeAll;
e.free;

(
~samples = Array.new;
~folder = PathName.new("/Users/wannes/streamSamples/"); // 0, Bells; 1, Kick; 2, Snare; 3, Scape; 4, Boeing; 5, Donder;
(
~folder.entries.do({
	arg path;
	~samples = ~samples.add(Buffer.read(s, path.fullPath));
});
);

SynthDef.new(\samples, {
	arg amp=1, out=~effects, buf, gate=1;
	var sig, env;
	env =  EnvGen.kr(Env.asr(0.01, 1.0, 2.5), gate, doneAction: 2);
	sig = PlayBuf.ar(2, buf, doneAction: 2);
	sig = sig * amp * env;
	Out.ar(out, sig);
}).add;

OSCdef.new(\osc_samples, {
	arg msg;
	if(msg[1] == 1, {
		Synth.new(\samples, [\buf, ~samples[msg[2]]]);
	});
	if((msg[1] == 0)&&(msg[2] == 3), {
		a = Synth.new(\samples, [\buf, ~samples[msg[2]]]);
	});
	if((msg[1] == 0)&&(msg[2] == 0), {
		a.set(\gate, 0);
	});
	("Sample Nr"+msg[2]).postln;
}, '/1/samples');
)

(
~effects = Bus.audio(s, 2); // TO DO: wordt bus waar ook al mijn signaal naartoe wordt gestuurd (in startup.scd fixen) > al OK door addToTail?

SynthDef.new(\effects, {
	arg in=~effects, decay=3, del_mix=(-1), rev_mix=0, rev_room=0.3, damp=0.2;
	var sig, delay;
	sig = In.ar(in, 2);
	delay = CombL.ar(sig, 0.5, SinOsc.kr(0.25).exprange(0.1,0.4), decay);  // Delay
	sig = XFade2.ar(sig, delay, del_mix, 1.1);
	sig = FreeVerb.ar(sig, rev_mix, rev_room, damp, add: 0.1);  // Reverb
	Out.ar(0, sig);
}).add;

e = Synth.new(\effects, addAction: \addToTail);
// e.free;

OSCdef.new(\osc_effects, {
	arg msg;
	if(msg[1] == 0, { // reverb
		e.set(\rev_mix, msg[2].linlin(0, 10, 0, 0.96), \rev_room, msg[2].linlin(0, 10, 0.2, 0.5) + 0.3);
		("Reverb"+msg[2].linlin(0, 10, 0, 0.96)).postln;
	});
	if(msg[1] == 1, { // delay
		e.set(\del_mix, msg[2].linlin(0, 10, (-1), 1), \decay, msg[2].linlin(0, 10, 0, 2) + 3);
		("Delay"+msg[2].linlin(0, 10, (-1), 0.9)).postln;
	});
}, '/2/effects');
)

// Eén audio bus voor alle effects msg[1] geeft door of rev of dist wordt aangesproken, msg[2] geeft dry/wet door
// distortion: { arg bus, numChan, preGain, postGain;
// (In.ar(bus, numChan) * preGain).distort * postGain;}
// {arg decay=3, mix=(-0.5);
// delay = CombL.ar(sig, 0.5, SinOSc.kr(0.3).exprange(0.1,0.4), decay);
// sig = XFade2.ar(sig, delay, mix)}
// dist = (sig * preGain).distort / 5;  // Distortion
// sig = XFade2.ar(sig, dist, dist_mix);


// extra: Twinkle Synth
(
SynthDef.new(\twsynth, {
	arg out, gate=0;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300, 1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	env = EnvGen.kr(Env.asr(1.5, 1.0, 2), gate, doneAction: 2)
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out, sig * env);
}).add;

t = Synth.new(\twsynth);

OSCdef.new(\osc_twsynth, {
	if(msg[1] == 0, {
		t.set(\gate, 1);
	});
	if(msg[1] == 1, {
		t.set(\gate, 0);
	});
}, '/3/synth');
)
// envelopes in synthdef nog testen, staan ze op de juiste plaats & werkt doneAction?