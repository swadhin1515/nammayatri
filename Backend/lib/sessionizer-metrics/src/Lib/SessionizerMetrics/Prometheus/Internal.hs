{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Lib.SessionizerMetrics.Prometheus.Internal where

import Kernel.Prelude
import Kernel.Types.Common
import Lib.SessionizerMetrics.Types.Event (EventStreamFlow)
import Prometheus as P

incrementCounter ::
  ( MonadReader r1 m,
    MonadGuid m,
    MonadTime m,
    MonadIO m,
    EventStreamFlow m r
  ) =>
  Text ->
  Text ->
  Text ->
  m ()
incrementCounter merchantId event deploymentVersion = do
  counterName <- asks (.eventRequestCounter)
  liftIO $ P.withLabel counterName (event, merchantId, deploymentVersion) P.incCounter

type EventCounterMetric = P.Vector P.Label3 P.Counter

registerEventRequestCounterMetric :: IO EventCounterMetric
registerEventRequestCounterMetric = P.register $ P.vector ("event", "merchant_name", "version") $ P.counter $ P.Info "event_count" ""
