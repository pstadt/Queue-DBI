#!perl -T

use strict;
use warnings;

use Test::Exception;
use Test::More tests => 4;

use DBI;
use Queue::DBI::Admin;


ok(
	my $dbh = DBI->connect(
		'dbi:SQLite:dbname=t/01-Admin/test_database',
		'',
		'',
		{
			RaiseError => 1,
		}
	),
	'Create connection to a SQLite database.',
);

can_ok(
	'Queue::DBI::Admin',
	'drop_tables',
);

subtest(
	'Check default tables.',
	sub
	{
		plan( tests => 4 );
		
		my $queue_admin;
		lives_ok(
			sub
			{
				$queue_admin = Queue::DBI::Admin->new(
					'database_handle' => $dbh,
				);
			},
			'Instantiate a new Queue::DBI::Admin object.',
		);
		
		lives_ok(
			sub
			{
				$queue_admin->drop_tables();
			},
			'Drop the default tables.',
		);
		
		my ( $tables_exist, $missing_tables ) = $queue_admin->has_tables();
		ok(
			!$tables_exist,
			'The default tables do not exist anymore.',
		);
		is_deeply(
			$missing_tables,
			[
				$Queue::DBI::DEFAULT_QUEUES_TABLE_NAME,
				$Queue::DBI::DEFAULT_QUEUE_ELEMENTS_TABLE_NAME,
			],
			'The list of missing tables is complete.',
		);
	}
);

subtest(
	'Check custom tables.',
	sub
	{
		plan( tests => 4 );
		
		my $queue_admin;
		lives_ok(
			sub
			{
				$queue_admin = Queue::DBI::Admin->new(
					'database_handle'           => $dbh,
					'queues_table_name'         => 'test_queues',
					'queue_elements_table_name' => 'test_queue_elements',
				);
			},
			'Instantiate a new Queue::DBI::Admin object.',
		);
		
		lives_ok(
			sub
			{
				$queue_admin->drop_tables();
			},
			'Drop the custom tables.',
		);
		
		my ( $tables_exist, $missing_tables ) = $queue_admin->has_tables();
		ok(
			!$tables_exist,
			'The custom tables do not exist anymore.',
		);
		is_deeply(
			$missing_tables,
			[
				'test_queues',
				'test_queue_elements',
			],
			'The list of missing tables is complete.',
		);
	}
);

