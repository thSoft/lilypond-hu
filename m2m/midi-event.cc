//
// midi-event.cc -- implement Midi_event
//
// copyright 1997 Jan Nieuwenhuizen <jan@digicash.com>

#include "m2m.hh"

Midi_event::Midi_event()
{
}

Moment
Midi_event::mom()
{
	return Moment( 0 );
}

void
Midi_event::output_mudela( Lily_stream& lily_stream_r, bool command_mode_bo )
{
	lily_stream_r << mudela_str( command_mode_bo ) << String( " " );
}

Midi_key::Midi_key( int accidentals_i, int minor_i )
{
	accidentals_i_ = accidentals_i;
	minor_i_ = minor_i;
	if ( !minor_i_ )
		key_i_ = ( ( accidentals_i % 7 )[ "cgdaebf" ] - 'a' + 2 ) % 7;
	else
		key_i_ = ( ( -accidentals_i % 7 )[ "fbeadg" ] - 'a' + 2 ) % 7;
}

String
Midi_key::mudela_str( bool command_mode_bo )
{
	String str = "key\\";
	if ( !minor_i_ ) 
		str += String( (char)( key_i_ - 2 + 'A'  ) );
	else
		str += String( (char)( key_i_ - 2 + 'a'  ) );
	if ( !command_mode_bo )
	    str =  String( '\\' ) + str;
	return str;
}

String
Midi_key::notename_str( int pitch_i )
{
	// this may seem very smart,
	// but it-s only an excuse not to read a notename table

	// major scale: do-do
	// minor scale: la-la ( = + 5 )
	static int notename_i_a[ 12 ] = { 0, 0, 1, 1, 2, 3, 3, 4, 4, 5, 5, 6 };
	int notename_i = notename_i_a[ ( minor_i_ * 5 + pitch_i ) % 12 ];
	
	static int accidentals_i_a[ 12 ] = { 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0 };
	int accidental_i = accidentals_i_a[ minor_i_ * 5 + pitch_i % 12 ];
	if ( accidentals_i_ < 0 ) {
		accidental_i = - accidental_i;
		notename_i = ( notename_i + 1 ) % 7;
	}

	String notename_str = (char)( ( ( notename_i + key_i_ - 2 ) % 7 ) + 'a' );
	while ( accidental_i-- > 0 )
		notename_str += "is";
	accidental_i++;
	while ( accidental_i++ < 0 )
		if ( ( notename_str == "a" ) || ( notename_str == "e" ) )
			notename_str += "s";
		else
			notename_str += "es";
	accidental_i--;
	String octave_str;

	octave_str += String( '\'', ( pitch_i - Midi_note::c0_pitch_i_c_ ) / 12 );
	octave_str += String( '`', ( Midi_note::c0_pitch_i_c_ - pitch_i ) / 12 );
	return octave_str + notename_str;
}

Midi_note::Midi_note( String name_str, Duration dur )
{
	// do i want pitch too?
	dur_ = dur;
	name_str_ = name_str;
}

String
Midi_note::mudela_str( bool command_mode_bo )
{
//	assert( !command_mode_bo );
// undefined ref to simple_plet_bo_ ??
//	if ( simple_plet_bo_ )
//		return name_str_ + Duration_convert::dur2_str( dur_ );

	//ugh
	String str;
	if ( dur_.plet_p_ )
		str += String( "\\plet{ " )
			+ String_convert::i2dec_str( dur_.plet_p_->iso_i_, 0, 0 )
			+ "/"
			+ String_convert::i2dec_str( dur_.plet_p_->type_i_, 0, 0 )
			+ " } ";

	str += name_str_;

	Duration dur = dur_;
	dur.set_plet( 0 );
	str += Duration_convert::dur2_str( dur );

	if ( dur_.plet_p_ )
		str += String( " \\plet{ 1/1 }" );
		
	return str;
}

Moment
Midi_note::mom()
{
	return Duration_convert::dur2_mom( dur_ );
}

Midi_tempo::Midi_tempo( int useconds_per_4_i )
{
	useconds_per_4_i_ = useconds_per_4_i;
	seconds_per_1_f_ = (Real)useconds_per_4_i_ * 4 / 1e6;
}

String
Midi_tempo::mudela_str( bool command_mode_bo )
{
//	assert( command_mode_bo );
	if ( !command_mode_bo )
		return "";
	String str = "tempo 4:";
	str += String( get_tempo_i( Moment( 1, 4 ) ) );
	return str;
}

int
Midi_tempo::get_tempo_i( Moment moment )
{
	return Moment( 60 ) / moment / Moment( seconds_per_1_f_ );
}

Midi_text::Midi_text( Midi_text::Type type, String text_str )
{
	type_ = type;
	text_str_ = text_str;
}

String
Midi_text::mudela_str( bool command_mode_bo )
{
	(void)command_mode_bo;
	if ( !text_str_.length_i() 
		|| ( text_str_.length_i() != (int)strlen( text_str_.ch_c_l() ) ) )
		return "";

	return "% " + text_str_ + "\n\t";
}

Midi_time::Midi_time( int num_i, int den_i, int clocks_4_i, int count_32_i )
	: sync_dur_( 8 )
{
	sync_f_ = 1.0;
	if ( count_32_i != 8 )
		warning( String( "#32 in quarter: " ) + String( count_32_i ), 0 );
	num_i_ = num_i;
	den_i_ = 2 << den_i;
	clocks_1_i_ = clocks_4_i * 4; 
}

int
Midi_time::clocks_1_i()
{
	return clocks_1_i_;
}

Duration
Midi_time::i2_dur( int time_i, int division_1_i )
{
	Moment mom = Duration_convert::i2_mom( time_i, division_1_i );
	mom /= sync_f_;

	dtor << "\n% (" << time_i << ", " << mom << "): "
		<< sync_f_ << endl;

	Duration dur = Duration_convert::mom2_dur( mom );
	if ( !dur.type_i_ ) {
		vtor << "\n% resyncing(" << time_i << ", " << mom << "): "
			<< sync_f_ << " -> ";
		mom *= sync_f_;
		sync_f_ = Duration_convert::sync_f( sync_dur_, mom );
		vtor << sync_f_ << endl;
		mom /= sync_f_;
		dur = Duration_convert::mom2_dur( mom );
	}

	return dur;
}

String
Midi_time::mudela_str( bool command_mode_bo )
{
	String str = "meter { "
		+ String( num_i_ ) + "*" + String( den_i_ ) 
		+ " }";
	if ( !command_mode_bo )
	    str =  String( '\\' ) + str;
	return str;
}

