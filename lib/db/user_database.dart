
import 'package:firebase_calendar/db/db_current_user_data.dart';
import 'package:firebase_calendar/db/user_organizations_db.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UserDataBase{

  static final UserDataBase instance= UserDataBase._init();


  static Database? _database;

  UserDataBase._init();


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {

    final uid='TEXT NOT NULL';
    final email='TEXT NOT NULL';
    final userName='TEXT NOT NULL';
    final userSurname='TEXT NOT NULL';
    final currentOrganizationId='TEXT NOT NULL';
    final userPhone='TEXT NOT NULL';
    final userUrl='TEXT NOT NULL';
    final groupIds='TEXT NOT NULL';
    final totalPoint='INTEGER NOT NULL';


    final userId='TEXT NOT NULL';
    final organizationId='TEXT NOT NULL';
    final organizationName='TEXT NOT NULL';
    final organizationUrl='TEXT NOT NULL';
    final isApproved='BOOLEAN NOT NULL';
    final userRole='TEXT NOT NULL';


    await db.execute('''
    
    CREATE TABLE $Users(
    
    ${UserFields.uid} $userId,
    ${UserFields.email} $email,
    ${UserFields.userName} $userName,
    ${UserFields.userSurname} $userSurname,
    ${UserFields.currentOrganizationId} $currentOrganizationId,
    ${UserFields.userPhone} $userPhone,
    ${UserFields.userUrl} $userUrl,
    ${UserFields.totalPoint} $totalPoint
    
    )
    
    ''');

    await db.execute('''

    CREATE TABLE $Organizations(
    ${UserOrgFields.userId} $userId,
    ${UserOrgFields.organizationId} $organizationId,
    ${UserOrgFields.organizationName} $organizationName,
    ${UserOrgFields.organizationUrl} $organizationUrl,
    ${UserOrgFields.isApproved} $isApproved,
    ${UserOrgFields.userRole} $userRole
    )
    ''');
  }



  Future<void> addAllUsers(List<CurrentUserDataDb> users,List<UserOrganizationsDb> orgs) async{


    final db = await instance.database;

    final usersToAdd=<CurrentUserDataDb>[];
    final orgsToAdd=<UserOrganizationsDb>[];
    readAllUsers().then((allUsers){
     users.forEach((user) {
       CurrentUserDataDb result=allUsers.firstWhere((element) => element.uid==user.uid,orElse: () =>Constants.DbUserHolder);
       if(result.uid==''){
         usersToAdd.add(user);
       }
     });
    });

    readAllOrgs().then((allOrgs) => {
      orgs.forEach((org) {
        UserOrganizationsDb result=allOrgs.firstWhere((element) =>
        element.uid==org.uid && element.organizationId==org.organizationId,orElse:()=> Constants.DbOrgHolder);
        if(result.uid==''){
          orgsToAdd.add(org);
        }
      })
    });


    print('added users $usersToAdd');
    print('added orgs $orgsToAdd');

    users.forEach((element) async {
      await db.insert(Users, element.toMap());
    });
    orgs.forEach((element) async {
      await db.insert(Organizations, element.toMap());
    });
  }


  Future<List<CurrentUserDataDb>> readAllUsers() async {
    final db = await instance.database;
    final result = await db.query(Users);
    return result.map((e) => CurrentUserDataDb.fromMap(e)).toList();
  }

  Future<List<UserOrganizationsDb>> readAllOrgs() async {
    final db = await instance.database;
    final result = await db.query(Organizations);
    return result.map((e) => UserOrganizationsDb.fromMap(e)).toList();
  }
}