{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Storage.Queries.Person.PersonDefaultEmergencyNumber where

import Domain.Types.Person
import Domain.Types.Person.PersonDefaultEmergencyNumber
import Kernel.Beam.Functions
import Kernel.External.Encryption
import Kernel.Prelude
import Kernel.Types.Common
import Kernel.Types.Id
import qualified Sequelize as Se
import qualified Storage.Beam.Person.PersonDefaultEmergencyNumber as BeamPDEN

create :: MonadFlow m => PersonDefaultEmergencyNumber -> m ()
create = createWithKV

createMany :: MonadFlow m => [PersonDefaultEmergencyNumber] -> m ()
createMany = traverse_ create

replaceAll :: MonadFlow m => Id Person -> [PersonDefaultEmergencyNumber] -> m ()
replaceAll (Id personId) pdenList = do
  deleteWithKV [Se.Is BeamPDEN.personId $ Se.Eq personId]
  createMany pdenList

findAllByPersonId :: MonadFlow m => Id Person -> m [PersonDefaultEmergencyNumber]
findAllByPersonId (Id personId) = findAllWithKV [Se.Is BeamPDEN.personId $ Se.Eq personId]

instance FromTType' BeamPDEN.PersonDefaultEmergencyNumber PersonDefaultEmergencyNumber where
  fromTType' BeamPDEN.PersonDefaultEmergencyNumberT {..} = do
    pure $
      Just
        PersonDefaultEmergencyNumber
          { personId = Id personId,
            name = name,
            mobileNumber = EncryptedHashed (Encrypted mobileNumberEncrypted) mobileNumberHash,
            mobileCountryCode = mobileCountryCode,
            createdAt = createdAt
          }

instance ToTType' BeamPDEN.PersonDefaultEmergencyNumber PersonDefaultEmergencyNumber where
  toTType' PersonDefaultEmergencyNumber {..} = do
    BeamPDEN.PersonDefaultEmergencyNumberT
      { BeamPDEN.personId = getId personId,
        BeamPDEN.name = name,
        BeamPDEN.mobileCountryCode = mobileCountryCode,
        BeamPDEN.mobileNumberHash = mobileNumber.hash,
        BeamPDEN.mobileNumberEncrypted = unEncrypted (mobileNumber.encrypted),
        BeamPDEN.createdAt = createdAt
      }
